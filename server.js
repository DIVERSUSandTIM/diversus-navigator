(function() {
  var Stream, a, app, cooked_argv, eco, express, fs, knownOpts, localOrCDN, nopt, nopts, port, shortHands;

  express = require("express");

  eco = require("eco");

  nopt = require("nopt");

  Stream = require("stream").Stream;

  fs = require('fs');

  cooked_argv = (function() {
    var _i, _len, _ref, _results;
    _ref = process.argv;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      a = _ref[_i];
      _results.push(a);
    }
    return _results;
  })();

  knownOpts = {
    is_local: Boolean,
    git_commit_hash: [String, null],
    git_branch_name: [String, null],
    port: [Stream, Number]
  };

  shortHands = {
    faststart: ["--skip_orlando", "--skip_poetesses"]
  };

  switch (process.env.NODE_ENV) {
    case 'development':
      cooked_argv.push("--faststart");
      cooked_argv.push("--is_local");
      cooked_argv.push("--git_commit_hash");
      cooked_argv.push("8e3849b");
      console.log(cooked_argv);
  }

  nopts = nopt(knownOpts, shortHands, cooked_argv, 2);

  switch (process.env.NODE_ENV) {
    case 'development':
      console.log(nopts);
  }

  app = express.createServer();

  localOrCDN = function(templatePath, isLocal) {
    var respondDude, template;
    template = fs.readFileSync(__dirname + templatePath, "utf-8");
    respondDude = (function(_this) {
      return function(req, res) {
        return res.send(eco.render(template, nopts));
      };
    })(this);
    return respondDude;
  };

  app.configure(function() {
    app.use(express.logger());
    app.set("views", __dirname + "/views");
    app.use(app.router);
    app.use("/huviz", express["static"](__dirname + '/lib'));
    app.use('/css', express["static"](__dirname + '/css'));
    app.use('/jquery-ui-css', express["static"](__dirname + '/node_modules/components-jqueryui/themes/smoothness'));
    app.use('/jquery-ui', express["static"](__dirname + '/node_modules/components-jqueryui'));
    app.use('/jquery', express["static"](__dirname + '/node_modules/jquery/dist'));
    app.use('/jquery-simulate-ext__libs', express["static"](__dirname + '/node_modules/jquery-simulate-ext/libs'));
    app.use('/jquery-simulate-ext__src', express["static"](__dirname + '/node_modules/jquery-simulate-ext/src'));
    app.use('/data', express["static"](__dirname + '/data'));
    app.use('/js', express["static"](__dirname + '/js'));
    app.use('/vendor', express["static"](__dirname + '/vendor'));
    app.use('/node_modules', express["static"](__dirname + '/node_modules'));
    app.use('/mocha', express["static"](__dirname + '/node_modules/mocha'));
    app.use('/chai', express["static"](__dirname + '/node_modules/chai'));
    app.use('/marked', express["static"](__dirname + '/node_modules/marked'));
    app.use('/docs', express["static"](__dirname + '/docs'));
    app.get("/orlonto.html", localOrCDN("/views/orlonto.html.eco", nopts.is_local));
    app.get("/yegodd.html", localOrCDN("/views/yegodd.html.eco", nopts.is_local));
    app.get("/tests", localOrCDN("/views/tests.html.eco", nopts.is_local));
    app.get("/", localOrCDN("/views/huvis.html.eco", nopts.is_local));
    return app.use(express["static"](__dirname + '/images'));
  });

  port = nopts.port || nopts.argv.remain[0] || process.env.PORT || default_port;

  console.log("Starting server on port: " + port + " localhost");

  app.listen(port, 'localhost');

}).call(this);
