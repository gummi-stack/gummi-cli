http = require 'http'
util = require 'util'
net = require 'net'
git = require './lib/git'
# director = require 'director'
Api = require './lib/api'
colors = require 'colors'
relativeDate = require 'relative-date'


args = process.argv[2..]
command = args[0]

config = 
	apiHost: '10.1.69.105'

# util.log command
# util.log git.branch + " " + git.name
api = new Api config 


# console.log command


if command is 'ps:restart'
	api.get "apps/#{git.name}/#{git.branch}/ps/restart", (data) ->
		util.log util.inspect data

if command is 'logs'
	api.on 'data', (data) ->
		process.stdout.write data
		
	api.getRaw "apps/#{git.name}/#{git.branch}/logs?tail=1", (data) ->


else if command is 'ps'
	api.get "apps/#{git.name}/#{git.branch}/ps", (processes) ->
		for process in processes
			date = relativeDate new Date process.time
			console.log " [#{process.opts.worker.yellow}] #{date}\t #{process.opts.cmd}" 
			# util.log util.inspect process

else if command is 'ps:stop'
	api.get "apps/#{git.name}/#{git.branch}/ps/stop", (data) ->
		if data.status is 'ok'
			console.log 'All processes stopped'
		else
			util.log util.inspect data


		
	

else if command is 'run'
	options = 
		host: '10.1.69.105'
		port: 80
		path: "/apps/#{git.name}/#{git.branch}/ps/"
		method: 'POST'
	
	cmd = process.argv[3..]

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
	req.write JSON.stringify command: cmd.join ' '

	req.end()
else 
	console.log "Unknown command"