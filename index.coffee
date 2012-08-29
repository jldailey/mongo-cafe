Readline = require 'readline'
Cs = require 'coffee-script'
db = null

Cs.eval """
db = do ->
	for arg in process.argv
		url = require('url').parse arg
		continue if "mongo:" isnt url?.protocol
		console.log "Connecting to " + url.href
		return require('mongoskin').db arg
	null
"""

io = Readline.createInterface
	input: process.stdin
	output: process.stdout

io.on 'line', (cmd) ->
	try
		console.log ret if ret = Cs.eval(cmd)
	catch err
		console.log err
	io.prompt()

io.on 'SIGINT', ->
	process.exit(1)

io.setPrompt "mongo> "
io.prompt()





