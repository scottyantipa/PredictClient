express = require 'express'
MongoClient = require('mongodb').MongoClient

app = express()
app.use(express.static __dirname+'/public')

MongoClient.connect 'mongodb://localhost:27017/predict', (err, db) ->
	if not err
		console.log 'Successful MongoDB connection'
		testData = db.collection 'testData'


exports.startServer = (port, path, callback) ->
	app.get '/', (req, res) -> res.sendfile '.public/index.html'
	app.listen port
	console.log 'Express listening on port #{port}'