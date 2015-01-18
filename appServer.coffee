#
# Sets up a static serever to serve app
# Note that the server doesnt actually do any rendering, even though I have
# it setup to look at server/views
# 

express = require 'express'
mongoose = require 'mongoose'

# setup express
app = express()
app.use(express.static __dirname+'/public') # sets up static server in public dir
app.set 'view engine', 'jade'
app.set 'views', __dirname+'/server/views' 
module.exports.app = app # expose this for everybody else


# brunch uses this line to start the server which is specified in config
exports.startServer = (port, path, callback) ->
	app.listen port
	console.log "Express started on #{port}"