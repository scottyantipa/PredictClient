express = require 'express'
mongoose = require 'mongoose'

# setup express
app = express()
app.use(express.static __dirname+'/public') # sets up static server in public dir
app.set 'view engine', 'jade'
app.set 'views', __dirname+'/server/views' 
module.exports.app = app # expose this for everybody else

mongoose.connect 'mongodb://localhost:27017/predict' # should abstract this
db = mongoose.connection
db.on 'error', console.error.bind(console, 'connection error:')
db.once 'open', () ->
	# I assume I need to open it here so it can be used later
	return

# brunch uses this line to start the server which is specified in config
exports.startServer = (port, path, callback) ->
	require './server/models/prediction' # Bootstrap models
	require './server/routes' # Bootstrap routes
	app.listen port
	console.log "Express started on #{port}"