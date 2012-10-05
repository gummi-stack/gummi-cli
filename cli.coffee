http = require 'http'
util = require 'util'
net = require 'net'

command = process.argv.splice 2

options = 
	host: '10.1.69.105'
	port: 80
	path: '/'
	method: 'POST'
	
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

req.write JSON.stringify command: command.join ' '

req.end()