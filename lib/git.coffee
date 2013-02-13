exec = require 'exec-sync'
exports.getBranch = ->
	
exports.__defineGetter__ 'name', ->
	[_, name] = exec("git config remote.origin.url").split /:/
	name.replace '/', ':'

exports.__defineGetter__ 'branch', ->
	exec 'git branch | grep "*" | tr -d "* \n"'
	