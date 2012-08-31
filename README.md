Mongo Cafe
----------

A REPL for Mongo using the CoffeeScript parser.
_id: "abc123", 

**Usage**

    npm install mongo-cafe
		mongoc mongo://localhost/test  # this opens a new REPL

		mongo://localhost/test> db.test.insert _id: "abc123", hello: "world"
		mongo://localhost/test> db.test.findOne hello: "world"
		{ _id: "abc123",
		  hello: "world"
		}
