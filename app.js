var express = require('express');
var expressSession = require('express-session');
var path = require('path');
var favicon = require('serve-favicon');
var logger = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser = require('body-parser');
var passport = require('passport');   
var LocalStrategy = require('passport-local').Strategy;
var bootstrap = require("express-bootstrap-service");
var nunjucks = require('nunjucks');
var nunjucksDate = require('nunjucks-date');

var index = require('./routes/index');
var student = require('./routes/student');
var reslife = require('./routes/reslife');
var housing = require('./routes/housing');


var app = express();


// view engine setup
app.set('views', path.join(__dirname, 'views'));


// uncomment after placing your favicon in /public
app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));
app.use(bootstrap.serve);

app.use(expressSession({ 
	secret: 'K94Q3ex4CGbxJkYNJq1I',
  resave: true,
  saveUninitialized: true
 })); 
app.use(passport.initialize()); 
app.use(passport.session());

var passport = require('passport');   
var LocalStrategy = require('passport-local').Strategy;
var auth = require('./auth/psprt.js');



app.use('/', index);
app.use('/students/', student);
app.use('/reslife/', reslife);
app.use('/housing/', housing);

app.set('view engine', 'html');


nunjucksDate.setDefaultFormat('MMMM Do YYYY, h:mm:ss a');

var env = nunjucks.configure('views', 
  {   autoescape: true,   
    express: app 
  }); 

nunjucksDate.install(env);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  var err = new Error('Not Found');
  err.status = 404;
  next(err);
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error', {
    title: 'Page Not Found',
    user: req.user
  });
});

module.exports = app;
