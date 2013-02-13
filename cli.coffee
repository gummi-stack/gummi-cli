http = require 'http'
util = require 'util'
net = require 'net'
git = require './lib/git'
# director = require 'director'
Api = require './lib/api'
colors = require 'colors'
relativeDate = require 'relative-date'
repl = require('repl')
fn = util.inspect # colorized output :)
util.inspect = (a, b, c) -> fn a, no, 5, yes 

args = process.argv[2..]

config = 
	apiHost: '10.1.69.105'

# util.log command
# util.log git.branch + " " + git.name
api = new Api config 


# console.log command
cmdList = {}

cmd = (name, cb) ->
	cmdList[name] = cb
	# console.log name

# fastcgi_keep_conn on; # < solution
# 
# proxy_buffering off;
# gzip off;

cmd 'ps:restart', (args, done) ->
	api.get "apps/#{git.name}/#{git.branch}/ps/restart", (data) ->
		# util.log util.inspect data
		runCommand 'ps', null, done

cmd 'logs', (args,done) ->
	api.on 'data', (data) ->
		process.stdout.write data
		
	api.getRaw "apps/#{git.name}/#{git.branch}/logs?tail=1", (data) ->
		done()

cmd 'ps', (args, done) ->
	api.get "apps/#{git.name}/#{git.branch}/ps", (processes) ->
		processes = processes.sort (a, b) ->
			b.opts.worker > b.opts.worker
			
		for process in processes
			date = relativeDate new Date process.time
			console.log " [#{process.opts.worker.yellow}] #{date}\t #{process.opts.cmd}\t #{process.state?.magenta}\t #{process.dynoData?.toadwartId}" 
		done()
		# util.log util.inspect process

cmd 'ps:scale', (args, done) ->
	unless args.length
		api.get "apps/#{git.name}/#{git.branch}/ps/scale", (processes) ->
			util.log util.inspect processes
			for process in processes
				date = relativeDate new Date process.time
				console.log " [#{process.opts.worker.yellow}] #{date}\t #{process.opts.cmd}" 
			done()
	else
		scales = {}
		for arg in args
			[name, count] = arg.split '='
			scales[name] = count
		api.post "apps/#{git.name}/#{git.branch}/ps/scale", scales: scales, (out) ->
			unless out or out.started
				util.log util.inspect out
			done()

cmd 'ps:stop', (args,done) ->
	api.get "apps/#{git.name}/#{git.branch}/ps/stop", (data) ->
		if data.status is 'ok'
			console.log 'All processes stopped'
		else
			util.log util.inspect data
		
		done()

		
	

cmd 'run', (args, done)->
	# TODO do api
	cmd = process.argv[3..]
	x = 
		command: cmd.join ' '
		env:
			COLUMNS: process.stdout.getWindowSize()[0]
			LINES: process.stdout.getWindowSize()[1]
			
	out = JSON.stringify x
	
	options = 
		host: config.apiHost
		port: 80
		path: "/apps/#{git.name}/#{git.branch}/ps/"
		method: 'POST'
		headers:
			'Accept': 'application/json'
			'Content-Type': 'application/json; charset=utf-8'
			'Content-Length': out.length
	
	
	req = http.request options, (res) ->
		buffer = ''
		res.on 'data', (data) ->
			buffer += data
		res.on 'end', ->
			r = JSON.parse buffer
			uri = r.rendezvousURI
			util.log uri
			[_, _, host, port]= uri.match /(.*):\/\/(.*):(\d+)/
			util.log "Connecting to #{host}:#{port}"
			console.log ''
		
			sock = net.connect port, host
			process.stdin.pipe sock 
			sock.pipe process.stdout

			sock.on 'connect', ->
				process.stdin.resume()
				process.stdin.setRawMode yes
		

			sock.on 'close', done = ->
				process.stdin.setRawMode no
				process.stdin.pause()
				sock.removeListener 'close', done
		

			process.stdin.on 'end', ->
				sock.destroy()
				console.log()
				done()

			process.stdin.on 'data', (b) ->
				if b.length == 1 && b[0] == 4
					process.stdin.emit('end')

	req.write out

	req.end()

command = args[0]

runCommand = (command, args, done) ->	
	if cmdList[command]	
		cmdList[command].call null, args, done
	else 
		console.log "Unknown command\n"
		console.log "  #{key}" for key of cmdList
		done()
		
if command		
	runCommand command, args[1..], () ->
else
	r = repl.start 
		prompt: "gummi> "
		input: process.stdin,
		output: process.stdout
		writer: () ->
			return ''
		eval: (cmd, context, filename, callback) ->
			cmd = cmd.substr(1).slice(0,-2)
			args = cmd.split ' '
			runCommand args[0], args[1..], () ->
				callback(null, '')
	for cmd, _ of cmdList
		r.context[cmd] = 1
	