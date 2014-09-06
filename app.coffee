express = require('express')
logger = require('morgan')
bodyParser = require('body-parser')
path = require('path')

app = express()

app.set('port', Number(process.env.PORT) or 3000)
app.use(express.static(path.join(__dirname, 'public')))
app.use(logger('combined'))
app.use(bodyParser.json())

app.get '/', (req, res) ->
  res.status(200).end()

app.post '/', (req, res) ->
  console.log req.body
  res.json(req.body)

app.listen app.get('port'), ->
  console.log 'Listening on http://localhost:3000/'
