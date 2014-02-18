debug = require('debug') 'api'
request = require 'request'
util    = require 'util'
http = require 'http'


handleError = (e) ->
	return console.log "Couldn't connect to api " if err?.code is 'ECONNREFUSED'
	throw err if err

class Api extends require('events').EventEmitter
	constructor: (@config) ->


	getStream: (path, done) ->
		url = "http://#{@config.apiHost}/#{path}"
		opts =
			uri: url
			headers:
				'Accept': 'application/json'
				'Content-Type': 'application/json; charset=utf-8'

		debug 'stream', url

		req = http.request opts, (res) =>
			res.setEncoding 'utf8'
			done res

		req.on 'error', handleError

	get: (url, done) ->
		@request 'GET', url, {}, yes, done


	post: (url, data, done) ->
		@request 'POST', url, data, yes, done


	request: (method, url, data, isJson, done) ->
		data = JSON.stringify data if data

		url = "http://#{@config.apiHost}/#{url}"
		debug url

		opts =
			uri: url
			method: method
			body: data
			headers:
				'Accept': 'application/json'
				'Content-Type': 'application/json; charset=utf-8'
				'Content-Length': data.length

		request opts, (err, res, body) =>
			return handleError err if err

			return done body if !isJson

			try
				json = JSON.parse body
			catch err
				util.log "Invalid response"
				util.log buffer
				process.exit 1

			done json



module.exports = Api
