Promise = require('bluebird')
gcm = require('node-gcm')
config = require('./config.json')

if process.env.REDISTOGO_URL
  rtg = require("url").parse(process.env.REDISTOGO_URL)
  redisClient = require("redis").createClient(rtg.port, rtg.hostname)
  redisClient.auth(rtg.auth.split(":")[1])
else
  redisClient = require("redis").createClient()

redisClient_lrange = Promise.promisify(redisClient.lrange, redisClient)
sender = new gcm.Sender(config.gcmKey or process.env.GCM_KEY)
sender_send = Promise.promisify(sender.send, sender)

module.exports =
  get: (authToken) ->
    if authToken
      return redisClient_lrange(authToken, 0, -1)
    else
      return Promise.resolve([])
  register: (authToken, device) ->
    redisClient.lpush(authToken, device) if authToken
  setMacClipboard: (macToken, text) ->
    redisClient.set(macToken, text) if macToken
  getMacClipboard: (macToken) ->
    return new Promise (resolve, reject) ->
      return resolve() unless macToken
      redisClient.multi()
        .get(macToken)
        .del(macToken)
        .exec (err, [text, rest...]) ->
          resolve(text)
  setAndroidClipboard: (androidTokens, text) ->
    registrationIds = androidTokens.map (t) -> t.replace(/^android-/, '')
    message = new gcm.Message(
      data:
        text: text
    )
    # message object, registrationIds array, number of retries
    sender_send(message, registrationIds, 4)
