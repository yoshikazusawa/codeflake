redis  = require 'redis'
crypto = require 'crypto'
client = redis.createClient()
config = JSON.parse require('fs').readFileSync('config.json')

createPath = (syntax, id) -> '/' + syntax + '/' + id
createKey  = (id) -> 'flake-' + id
random     = -> Math.floor Math.random() * 10000
recentKey  = 'recentflakes'
createId = ->
    seed = [random(), Date.now()].join ''
    crypto
        .createHash 'sha1'
        .update seed
        .digest 'hex'
        .substring 0, 12


# models
deadline = 60 * 60 * 24 * 180
entry =
    get: (id, callback) ->
        client.get id, callback
    put: (id, flake, callback) ->
        client.set id, flake, ->
            client.expire id, deadline, callback

recent =
    get: (callback) ->
        client.lrange recentKey, 0, 20, callback
    put: (path, callback) ->
        client.lrem recentKey, 0, path, ->
            client.lpush recentKey, path, ->
                client.ltrim recentKey, 0, 100, callback

# controllers
root = (req, res) ->
    res.redirect createPath(config.syntaxes[0], createId())

index = (req, res) ->
    { syntax, id, format } = req.params
    entry.get createKey(id), (err, flake) ->
        recent.get (err, recent) ->
            return res.send(flake, 'Content-Type' : 'text/plain') if format is 'plain'
            return res.json({ id: id, flake: flake }) if format is 'json'
            res.render 'index',
                title : 'codeflake',
                id    : id,
                syntax: syntax,
                langs : config.syntaxes,
                recent: recent,
                flake : flake,
                path  : createPath(syntax, id)

post = (req, res) ->
    id = req.params.id or createId()
    syntax = req.body.syntax
    flake = req.body.flake
    return res.redirect '/' unless /[0-9a-z]+/.test flake
    entry.put createKey(id), req.body.flake, () ->
        path = createPath syntax, id
        recent.put path, -> res.redirect path

exports.root  = root
exports.index = index
exports.post  = post
