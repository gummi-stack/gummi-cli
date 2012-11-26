http = require 'http'
util = require 'util'
net = require 'net'
git = require './lib/git'
# director = require 'director'
Api = require './lib/api'
colors = require 'colors'
relativeDate = require 'relative-date'

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


cmd 'ps:restart', ->
	api.get "apps/#{git.name}/#{git.branch}/ps/restart", (data) ->
		util.log util.inspect data

cmd 'logs', ->
	api.on 'data', (data) ->
		process.stdout.write data
		
	api.getRaw "apps/#{git.name}/#{git.branch}/logs?tail=1", (data) ->


cmd 'ps', ->
	api.get "apps/#{git.name}/#{git.branch}/ps", (processes) ->
		processes = processes.sort (a, b) ->
			b.opts.worker > b.opts.worker
			
		for process in processes
			date = relativeDate new Date process.time
			console.log " [#{process.opts.worker.yellow}] #{date}\t #{process.opts.cmd}\t #{process.state?.magenta}" 
			# util.log util.inspect process

cmd 'ps:scale', () ->
	unless arguments.length
		api.get "apps/#{git.name}/#{git.branch}/ps/scale", (processes) ->
			util.log util.inspect processes
			for process in processes
				date = relativeDate new Date process.time
				console.log " [#{process.opts.worker.yellow}] #{date}\t #{process.opts.cmd}" 
	else
		scales = {}
		for arg in arguments
			[name, count] = arg.split '='
			scales[name] = count
		api.post "apps/#{git.name}/#{git.branch}/ps/scale", scales: scales, (out) ->
			unless out or out.started
				util.log util.inspect out
			

cmd 'ps:stop', ->
	api.get "apps/#{git.name}/#{git.branch}/ps/stop", (data) ->
		if data.status is 'ok'
			console.log 'All processes stopped'
		else
			util.log util.inspect data


		
	

cmd 'run', ->
	util.log util.inspect console
	# TODO do api
	cmd = process.argv[3..]
	x = 
		command: cmd.join ' '
		env:
			COLUMNS: process.stdout.getWindowSize()[0]
			LINES: process.stdout.getWindowSize()[1]
			
	out = JSON.stringify x
	
	util.log util.inspect out
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

			process.stdin.on 'data', (b) ->
				if b.length == 1 && b[0] == 4
					process.stdin.emit('end')

	req.write out

	req.end()

command = args[0]
	
if cmdList[command]	
	cmdList[command].apply null, args[1..]
else 
	console.log "Unknown command\n"
	console.log "  #{key}" for key of cmdList
