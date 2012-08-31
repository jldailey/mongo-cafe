require 'bling'
Readline = require 'readline'
Cs = require 'coffee-script'

usage = ->
	console.error "Usage: #{process.argv[0]} mongo://host:port/database"
	process.exit 1

exports.run = run = (input, output) ->
	urlString = null
	for arg in process.argv
		url = require('url').parse arg
		if "mongo:" is url?.protocol
			urlString = url.href
			break
	if not urlString?
		usage()
	console.log "Connecting to " + urlString

	Cs.eval """
	db = do ->
		db = require('mongoskin').db "#{urlString}"
		db.collections (err, collections) -> collections.forEach (coll) -> db.bind coll.collectionName
		db
	callback = cb = (err, data) ->
		(console.error err) if err
		(console.log data) if data
	"""

	describeDb = (obj) -> "mongo://#{obj.serverConfig.host}:#{obj.serverConfig.port}/#{obj.databaseName}"
	describeColl = (obj) -> describeDb(obj.skinDb._dbconn) + "/collection/#{obj.collectionName}"

	process.on 'uncaughtException', (err) -> console.log "Uncaught: #{err}"

	io = Readline.createInterface
		input: input
		output: output

	io.on 'line', (cmd) ->
		try
			if cmd?.length < 1 then return
			ret = Cs.eval("it = " + cmd)
			if ret?
				console.log switch true
					when "_dbconn" of ret then describeDb(ret._dbconn)
					when "collectionName" of ret then "" # describeColl(ret)
					when "cursor" of ret
						ret.limit(20).toArray (err, data) ->
							(console.log err) if err
							(console.log item) for item in data when data
						if ret.count() > 20
							console.log "...More..."
						""
					else ret
		catch err
			console.log err
		finally
			io.prompt()

	io.on 'SIGINT', ->
		process.exit(1)

	io.setPrompt "mongo> "
	io.prompt()

if require.main is module
	run process.stdin, process.stdout

