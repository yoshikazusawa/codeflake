redis  = require 'redis'
crypto = require 'crypto'
client = redis.createClient()

createPath = (syntax, id) -> '/' + syntax + '/' + id
random     = -> Math.floor Math.random() * 10000

entry = do ->
    get: (id, callback) ->
        client.get id, callback
    put: (id, flake, callback) ->
        client.set id, flake, ->
            client.expire id, 60 * 60 * 24, callback
        

recent = do ->
    key = 'recentflakes'
    get: (callback) ->
        client.lrange key, 0, 10, callback
    put: (path, callback) ->
        client.lrem  key, 0, path, ->
            client.lpush key, path, ->
                client.ltrim key, 0, 100, callback

root = (req, res) ->
    digest = do ->
        seed = [random(), Date.now()].join ''
        crypto.createHash('sha1').update(seed).digest('hex')
    res.redirect createPath('perl', digest.substring(0, 12))

index = (req, res) ->
    { syntax, id } = req.params
    entry.get id, (err, flake) ->
        recent.get (err, recent) ->
            res.render 'index',
                title : 'codeflake',
                id    : id,
                syntax: syntax,
                langs : 'perl javascript diff'.split(/\s/),
                recent: recent,
                flake : flake,
                path  : createPath(syntax, id)

post = (req, res) ->
    { id } = req.params
    syntax = req.body.syntax
    entry.put id, req.body.flake, () ->
        path = createPath syntax, id
        recent.put path, -> res.redirect path

exports.root  = root
exports.index = index
exports.post  = post
