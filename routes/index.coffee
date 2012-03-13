redis  = require 'redis'
crypto = require 'crypto'
client = redis.createClient()

createPath = (syntax, id) -> '/' + syntax + '/' + id
createKey  = (id) -> 'flake-' + id
random     = -> Math.floor Math.random() * 10000
recentKey  = 'recentflakes'

# models
entry =
    get: (id, callback) ->
        client.get id, callback
    put: (id, flake, callback) ->
        client.set id, flake, ->
            client.expire id, 60 * 60 * 24, callback

recent =
    get: (callback) ->
        client.lrange recentKey, 0, 20, callback
    put: (path, callback) ->
        client.lrem recentKey, 0, path, ->
            client.lpush recentKey, path, ->
                client.ltrim recentKey, 0, 100, callback

# controllers
root = (req, res) ->
    digest = do ->
        seed = [random(), Date.now()].join ''
        crypto.createHash('sha1').update(seed).digest('hex')
    res.redirect createPath('perl', digest.substring(0, 12))

index = (req, res) ->
    { syntax, id, format } = req.params
    entry.get createKey(id), (err, flake) ->
        recent.get (err, recent) ->
            return res.send(flake) if format is 'plain'
            return res.json({ id: id, flake: flake }) if format is 'json'
            res.render 'index',
                title : 'codeflake',
                id    : id,
                syntax: syntax,
                langs : 'perl javascript diff mysql'.split(/\s/),
                recent: recent,
                flake : flake,
                path  : createPath(syntax, id)

post = (req, res) ->
    { id } = req.params
    syntax = req.body.syntax
    flake = req.body.flake
    res.redirect '/' unless /[0-9a-z]+/.test(flake)
    entry.put createKey(id), req.body.flake, () ->
        path = createPath syntax, id
        recent.put path, -> res.redirect path

exports.root  = root
exports.index = index
exports.post  = post
