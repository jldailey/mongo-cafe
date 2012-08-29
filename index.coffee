Readline = require 'readline'
Cs = require 'coffee-script'
db = null

Cs.eval """
db = do ->
	for arg in process.argv
		url = require('url').parse arg
		continue if "mongo:" isnt url?.protocol
		console.log "Connecting to " + url.href
		db = require('mongoskin').db arg
		db.collections (err, collections) -> collections.forEach (coll) -> db.bind coll.collectionName
		return db
	null
callback = cb = (err, data) ->
	(console.error err) if err
	(console.log data) if data
"""

describeDb = (obj) -> "mongo://#{obj.serverConfig.host}:#{obj.serverConfig.port}/#{obj.databaseName}"
describeColl = (obj) -> describeDb(obj.skinDb._dbconn) + "/#{obj.collectionName}"

io = Readline.createInterface
	input: process.stdin
	output: process.stdout

io.on 'line', (cmd) ->
	try
		ret = Cs.eval(cmd)
		if ret?
			console.log switch true
				when "_dbconn" of ret then describeDb(ret._dbconn)
				when "collectionName" of ret then "" # describeColl(ret)
				when "cursorId" of ret then ret.toArray()
				else ret
	catch err
		console.log err
	io.prompt()

io.on 'SIGINT', ->
	process.exit(1)

io.setPrompt "mongo> "
io.prompt()





