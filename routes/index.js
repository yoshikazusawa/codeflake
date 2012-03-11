(function() {
  var client, createPath, crypto, entry, index, post, random, recent, redis, root;

  redis = require('redis');

  crypto = require('crypto');

  client = redis.createClient();

  createPath = function(syntax, id) {
    return '/' + syntax + '/' + id;
  };

  random = function() {
    return Math.floor(Math.random() * 10000);
  };

  entry = (function() {
    return {
      get: function(id, callback) {
        return client.get(id, callback);
      },
      put: function(id, flake, callback) {
        return client.set(id, flake, function() {
          return client.expire(id, 60 * 60 * 24, callback);
        });
      }
    };
  })();

  recent = (function() {
    var key;
    key = 'recentflakes';
    return {
      get: function(callback) {
        return client.lrange(key, 0, 10, callback);
      },
      put: function(path, callback) {
        return client.lrem(key, 0, path, function() {
          return client.lpush(key, path, function() {
            return client.ltrim(key, 0, 100, callback);
          });
        });
      }
    };
  })();

  root = function(req, res) {
    var digest;
    digest = (function() {
      var seed;
      seed = [random(), Date.now()].join('');
      return crypto.createHash('sha1').update(seed).digest('hex');
    })();
    return res.redirect(createPath('perl', digest.substring(0, 12)));
  };

  index = function(req, res) {
    var id, syntax, _ref;
    _ref = req.params, syntax = _ref.syntax, id = _ref.id;
    return entry.get(id, function(err, flake) {
      return recent.get(function(err, recent) {
        return res.render('index', {
          title: 'codeflake',
          id: id,
          syntax: syntax,
          langs: 'perl javascript diff'.split(/\s/),
          recent: recent,
          flake: flake,
          path: createPath(syntax, id)
        });
      });
    });
  };

  post = function(req, res) {
    var id, syntax;
    id = req.params.id;
    syntax = req.body.syntax;
    return entry.put(id, req.body.flake, function() {
      var path;
      path = createPath(syntax, id);
      return recent.put(path, function() {
        return res.redirect(path);
      });
    });
  };

  exports.root = root;

  exports.index = index;

  exports.post = post;

}).call(this);
