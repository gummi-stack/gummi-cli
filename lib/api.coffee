request = require 'request'
util    = require 'util'
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
			uri: "http://#{@config.apiHost}/#{url}"
			method: method
			body: data
			headers:
				'Accept': 'application/json'
				'Content-Type': 'application/json; charset=utf-8'
				'Content-Length': data.length

		request opts, (err, res, body) =>
			return console.log "Couldn't connect to api #{opts.host}." if err?.code is 'ECONNREFUSED'
			throw err if err

			return done body if !isJson

			try
				json = JSON.parse body
			catch err
				util.log "Invalid response"
				util.log buffer
				process.exit 1

			done json



module.exports = Api
