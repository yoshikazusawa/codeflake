express = require 'express'
routes = require './routes'

app = module.exports = express.createServer(
    express.bodyParser()
  , express.methodOverride()
)

app.configure ->
    app.set 'view engine', 'jade'
    app.use express.static(__dirname + '/public')

app.configure 'development', ->
    app.use express.errorHandler(dumpExceptions: true, showStack: true)

app.configure 'production', ->
    app.use express.errorHandler()

app.get '/', routes.root
app.get '/:syntax?/:id?/:format?', routes.index
app.post '/:syntax?/:id?', routes.post
app.listen 3000

console.log "codeflake running on port %d in %s mode!", app.address().port, app.settings.env
