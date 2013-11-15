mongoose = require 'mongoose'
predictions = require './controllers/predictions'
app = module.parent.exports.app # get app from parent module (appServer)

# Note: '/' is taken care of in appServer because express
# sets up a static server in public dir

app.get '/predictions', predictions.all