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

copy = null
app.post '/', (req, res) ->
  console.log req.body
  copy = req.body.text
  devices.get(req.body.authToken).then (devices) ->
    for device in devices
      console.log device
    res.status(200).end()

app.post '/register', (req, res) ->
  devices.register(req.body.authToken, req.body.device)
  res.status(200).end()

app.get '/devices', (req, res) ->
  devices.get(req.query.authToken).then (devices) ->
    res.json({devices})

app.get '/mac', (req, res) ->
  if copy
    res.json({text: copy})
    copy = null
  else
    res.json({})

app.listen app.get('port'), ->
  console.log 'Listening on http://localhost:3000/'
