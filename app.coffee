express = require('express')
logger = require('morgan')
bodyParser = require('body-parser')
path = require('path')

app = express()

if process.env.REDISTOGO_URL
  rtg = require("url").parse(process.env.REDISTOGO_URL)
  redisClient = require("redis").createClient(rtg.port, rtg.hostname)
  redisClient.auth(rtg.auth.split(":")[1])
else
  redisClient = require("redis").createClient()

app.set('port', Number(process.env.PORT) or 3000)
app.use(express.static(path.join(__dirname, 'public')))
app.use(logger('combined'))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded())

copy = null
app.post '/', (req, res) ->
  console.log req.body
  authToken = req.body.authToken
  copy = req.body.text
  res.status(200).end()

app.post '/register', (req, res) ->
  authToken = req.body.authToken
  if authToken
    device = req.body.device
    redisClient.lpush(authToken, device)
  res.status(200).end()

app.get '/devices', (req, res) ->
  authToken = req.query.authToken
  if authToken
    redisClient.lrange authToken, 0, -1, (err, devices) ->
      res.status(500).end() if err
      res.json({devices})
  else
    devices = []
    res.json({devices})

app.get '/mac', (req, res) ->
  if copy
    res.json({text: copy})
    copy = null
  else
    res.json({})

app.listen app.get('port'), ->
  console.log 'Listening on http://localhost:3000/'
