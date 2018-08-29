
express = require("express")
eco = require("eco")

# https://github.com/npm/nopt
nopt = require("nopt")
Stream = require("stream").Stream
fs = require('fs')
cooked_argv = (a for a in process.argv)
knownOpts =
  is_local: Boolean
  git_commit_hash: [String, null]
  git_branch_name: [String, null]
  port: [Stream, Number]
shortHands =
  faststart: ["--skip_orlando", "--skip_poetesses"]
  #faststart: []

switch process.env.NODE_ENV
  when 'development'
    cooked_argv.push("--faststart")
    cooked_argv.push("--is_local")
    cooked_argv.push("--git_commit_hash")
    cooked_argv.push("8e3849b") # cafeb0b is funnier
    console.log cooked_argv

nopts = nopt(knownOpts, shortHands, cooked_argv, 2)

switch process.env.NODE_ENV
  when 'development'
    console.log nopts

app = express.createServer()

# https://github.com/sstephenson/eco
localOrCDN = (templatePath, isLocal) ->
  template = fs.readFileSync __dirname + templatePath, "utf-8"
  respondDude = (req, res) =>
    res.send(eco.render(template, nopts))
  return respondDude

app.configure ->
  app.use express.logger()
  app.set "views", __dirname + "/views"
  app.use app.router
  app.use("/huviz", express.static(__dirname + '/lib'))
  app.use('/css', express.static(__dirname + '/css'))
  app.use('/jquery-ui-css',
    express.static(__dirname + '/node_modules/components-jqueryui/themes/smoothness'))
  app.use('/jquery-ui',
    express.static(__dirname + '/node_modules/components-jqueryui'))
  # TODO use /jquery-ui/jquery-ui.js instead once "require not found is fixed"
  #   app.use('/jquery-ui',
  #     express.static(__dirname + '/node_modules/jquery-ui'))
  app.use('/jquery', express.static(__dirname + '/node_modules/jquery/dist'))
  app.use('/jquery-simulate-ext__libs', express.static(__dirname + '/node_modules/jquery-simulate-ext/libs'))
  app.use('/jquery-simulate-ext__src', express.static(__dirname + '/node_modules/jquery-simulate-ext/src'))
  app.use('/data', express.static(__dirname + '/data'))
  app.use('/js', express.static(__dirname + '/js'))
  app.use('/vendor', express.static(__dirname + '/vendor'))
  app.use('/node_modules', express.static(__dirname + '/node_modules'))
  app.use('/mocha', express.static(__dirname + '/node_modules/mocha'))
  app.use('/chai', express.static(__dirname + '/node_modules/chai'))
  app.use('/marked', express.static(__dirname + '/node_modules/marked'))
  app.use('/docs', express.static(__dirname + '/docs'))
  app.get "/orlonto.html", localOrCDN("/views/orlonto.html.eco", nopts.is_local)
  app.get "/yegodd.html", localOrCDN("/views/yegodd.html.eco", nopts.is_local)
  #app.get "/experiment.html", localOrCDN("/views/experiment.html", nopts.is_local)
  #app.get "/experiment.js", localOrCDN("/views/experiment.js", nopts.is_local)
  app.get "/tests", localOrCDN("/views/tests.html.eco", nopts.is_local)
  app.get "/", localOrCDN("/views/huvis.html.eco", nopts.is_local)
  app.use express.static(__dirname + '/images') # for /favicon.ico

port = nopts.port or nopts.argv.remain[0] or process.env.PORT or default_port

console.log "Starting server on port: #{port} localhost"
app.listen port, 'localhost'
