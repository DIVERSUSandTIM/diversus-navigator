
#require("coffee-script")
stitch  = require("stitch")
express = require("express")
eco = require("eco")
argv = process.argv.slice(2)

ss = require('./js/sortedset')
oink = ss.SortedSet()

IS_LOCAL = ('--is_local' in argv)
SKIP_ORLANDO = ('--skip_orlando' in argv)
SKIP_POETESSES = ('--skip_poetesses' in argv)

nopt = require("nopt")
Stream = require("stream").Stream
knownOpts =
  is_local: Boolean
  skip_orlando: Boolean
  skip_poetesses: Boolean
  git_commit_hash: [String, null]
  port: [Stream, Number]
nopts = nopt(knownOpts, {}, process.argv, 2)
console.log nopts

pkg = stitch.createPackage(
  # Specify the paths you want Stitch to automatically bundle up
  paths: [ __dirname + "/src" ]

  # Specify your base libraries
  dependencies: [
    __dirname + '/node_modules/async/lib/async.js',
    __dirname + '/js/sortedset.js',
    __dirname + '/js/hsv.js',
    __dirname + '/js/hsl.js',
    #__dirname + '/lib/jquery.js',
    #__dirname + '/lib/jquery-ui.min.js',
    #__dirname + '/lib/d3.v3.min.js', # before fisheye
    #__dirname + '/lib/jq.min.js',
    __dirname + '/lib/fisheye.js',
    __dirname + '/lib/green_turtle.js'
    __dirname + '/js/quadParser.js'    
  ]
)
app = express.createServer()

# a package for code2flow to visualize
just_huviz = stitch.createPackage(
  paths: [ __dirname + "/src" ]
  dependencies: [
    __dirname + '/js/sortedset.js',
  ]
)

fs = require('fs')

# https://github.com/sstephenson/eco
localOrCDN = (templatePath, isLocal) ->
  template = fs.readFileSync __dirname + templatePath, "utf-8"
  respondDude = (req, res) =>
    res.send(eco.render(template, nopts))
  return respondDude

libxmljs = require "libxmljs"       # https://github.com/polotek/libxmljs
# https://github.com/polotek/libxmljs/wiki/Document
#   NOTE attribute names and tag names are CASE SENSITIVE!!!!?!!???

createSnippetServer = (xmlFileName, uppercase) ->
  if not uppercase? or uppercase
    id_in_case = "ID"
  else
    id_in_case = "id"
  doc = null
  nodes_with_id = []
  elems_by_id = {}
  elems_idx_by_id = {}
  makeXmlDoc = (err, data) ->
    if err
      console.error err
    else
      console.log "parsing #{xmlFileName}..."
      started = new Date().getTime() / 1000
      doc = libxmljs.parseXml(data.toString())
      #doc = new dom().parseFromString(data.toString())
      finished = new Date().getTime() / 1000
      console.log "finished parsing #{xmlFileName} in #{finished - started} sec"

      if true
        console.log "finding IDs in #{xmlFileName}..."
        started = new Date().getTime() / 1000
        # http://stackoverflow.com/questions/4107831/an-xpath-query-that-returns-all-nodes-with-the-id-attribute-set
        nodes_with_id = doc.find('//*[@' + id_in_case + ']')  #  //*[@ID]
        #nodes_with_id = doc.find('//*[@ID!=""]')
        count = nodes_with_id.length
        finished = new Date().getTime() / 1000
        console.log "finished parsing #{xmlFileName} in #{finished - started} sec found: #{count}"

        if true
          started = new Date().getTime() / 1000
          for elem,i in nodes_with_id
            thing = elem.get("@" + id_in_case);
            id = thing.value() # @id  OR  @ID
            #console.log "   ",id,i
            elems_idx_by_id[id] = i
          finished = new Date().getTime() / 1000
          console.log "finished indexing #{xmlFileName} in #{finished - started} sec"

  getSnippetById = (req, res) ->
    if doc
      started = new Date().getTime()
      elem = nodes_with_id[elems_idx_by_id[req.params.id]]
      finished = new Date().getTime()
      sec = (finished - started) / 1000
      if elem?
        snippet = elem.toString()
        res.send(snippet)
      else
        res.send("not found")
    else
      res.send("doc still parsing")
  fs.readFile(xmlFileName, makeXmlDoc)
  return getSnippetById

app.configure ->
  app.use express.logger()
  app.set "views", __dirname + "/views"
  app.use app.router
  #app.use express.static(__dirname + "/public")
  app.use express.static(__dirname)
  #app.use express.static(__dirname + '/js')
  app.use express.static(__dirname + '/lib')
  app.use express.static(__dirname + '/data')
  app.use express.static(__dirname + '/docs')
  app.use express.static(__dirname + '/node_modules')
  app.get "/application.js", pkg.createServer()
  app.get "/just_huviz.js", just_huviz.createServer()
  app.get "/huvis.html", localOrCDN("/views/huvis.html.eco", nopts.is_local)
  app.get "/orlonto.html", localOrCDN("/views/orlonto.html.eco", nopts.is_local)

# http://regexpal.com/
port = nopts.port or process.env.PORT or 9999
if not nopts.skip_orlando
  app.get "/snippet/orlando/:id([A-Za-z0-9-_]+)/",
      createSnippetServer("orlando_all_entries_2013-03-04.xml", true)

if not nopts.skip_poetesses
  app.get "/snippet/poetesses/:id([A-Za-z0-9-_]+)/",
      createSnippetServer("poetesses_decomposed.xml", false)

console.log "Starting server on port: #{port}"
app.listen port