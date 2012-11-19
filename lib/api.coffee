http = require 'http'
util = require 'util'
EventEmitter = require('events').EventEmitter

class Api extends EventEmitter
	constructor: (@config) ->

	getRaw: (url, done) ->
		@request 'GET', url, {}, no, done
		
	get: (url, done) ->
		@request 'GET', url, {}, yes, done
		
	post: (url, data, done) ->
		@request 'POST', url, data, yes, done
		
	request: (method, url, data, isJson, done) ->
		data = JSON.stringify data if data 
		
		opts = 
			host: @config.apiHost
			port: 80
			path: "/" + url
			method: method
			headers:
				'Accept': 'application/json'
				'Content-Type': 'application/json; charset=utf-8'
				'Content-Length': data.length

		req = http.request opts, (res) =>
			res.setEncoding 'utf8' 
			
			buffer = ''
			res.on 'data', (chunk) =>
				@emit 'data', chunk
				buffer += chunk
			res.on 'end', () ->
				if isJson
					try 
						json = JSON.parse buffer
					catch err
						util.log "Invalid response"
						util.log buffer
						process.exit 1
					done json 
				else 
					done buffer

		req.on 'error', (err) ->
			if err.code is 'ECONNREFUSED'
				console.log "Couldn't connect to api #{opts.host}."
				return
			throw err

		req.write data
		req.end()
	
module.exports = Api