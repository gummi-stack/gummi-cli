exec  = require('child_process').exec
async = require 'async'



getName = (cb) ->
	exec 'git config remote.origin.url', (err, stdout, stderr) ->
		return cb err if err

		[_, name] = stdout.split /:/
		cb null, name.replace('/', ':').replace('\n', '')


getBranch = (cb) ->
	exec 'git branch | grep "*" | tr -d "* \n"', (err, stdout, stderr) ->
		return cb err if err

		cb null, stdout


exports.getRepo = (cb) ->
	tasks = [getName, getBranch]

	async.parallel tasks, (err, res) ->
		cb err, res[0], res[1]

