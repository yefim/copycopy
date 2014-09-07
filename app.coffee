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
  currentDevice = req.body.device
  devices.get(req.body.authToken).then (devices) ->
    console.log devices
    for device in devices
      continue if device == currentDevice
      if device.match(/^mac-/)
        devices.setMacClipboard(device + req.body.authToken, req.body.text)
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
