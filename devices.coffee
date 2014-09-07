Promise = require("bluebird")

if process.env.REDISTOGO_URL
  rtg = require("url").parse(process.env.REDISTOGO_URL)
  redisClient = require("redis").createClient(rtg.port, rtg.hostname)
  redisClient.auth(rtg.auth.split(":")[1])
else
  redisClient = require("redis").createClient()

redisClient_lrange = Promise.promisify(redisClient.lrange, redisClient)

macify = (authToken) -> "#{authToken}-mac"

module.exports =
  get: (authToken) ->
    if authToken
      return redisClient_lrange(authToken, 0, -1)
    else
      return Promise.resolve([])
  register: (authToken, device) ->
    redisClient.lpush(authToken, device) if authToken
  setMacClipboard: (authToken, text) ->
    redisClient.set(macify(authToken), text) if authToken
  getMacClipboard: (authToken) ->
    return new Promise (resolve, reject) ->
      return resolve() unless authToken
      key = macify(authToken)
      redisClient.multi()
        .get(key)
        .del(key)
        .exec (err, [text, rest...]) ->
          resolve(text)
