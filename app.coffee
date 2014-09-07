express = require('express')
logger = require('morgan')
bodyParser = require('body-parser')
path = require('path')
devices = require('./devices')

app = express()

app.set('port', Number(process.env.PORT) or 3000)
app.use(express.static(path.join(__dirname, 'public')))
app.use(logger('combined'))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded())

###
{ authToken, device, text }
###
app.post '/', (req, res) ->
  console.log req.body
  # only do this if they have a mac device
  # devices.setMacClipboard(req.body.authToken, req.body.text)
  currentDeviceToken = req.body.device
  devices.get(req.body.authToken).then (deviceTokens) ->
    console.log devices
    for deviceToken in deviceTokens
      continue if deviceToken == currentDeviceToken
      if deviceToken.match(/^mac-/)
        devices.setMacClipboard(deviceToken + req.body.authToken, req.body.text)
    res.status(200).end()

###
{ authToken, device }
###
app.post '/register', (req, res) ->
  devices.register(req.body.authToken, req.body.device)
  res.status(200).end()

app.get '/devices', (req, res) ->
  devices.get(req.query.authToken).then (devices) ->
    res.json({devices})

###
{ authToken, device }
###
app.get '/mac', (req, res) ->
  devices.getMacClipboard(req.query.device + req.query.authToken).then (text) ->
    if text
      res.json({text})
    else
      res.json({})

app.listen app.get('port'), ->
  console.log 'Listening on http://localhost:3000/'
