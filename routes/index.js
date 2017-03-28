var express = require('express');
var router = express.Router();

var db = require('../queries.js');
var authHelpers = require('../auth/_helper.js');
var auth = require('../auth/psprt.js');
var bcrypt = require('bcrypt');

var SALT_WORK_FACTOR = 10;

/* GET home page. */

//user: req.user --> This must be in every res.render parameter set





router.get('/', function(req, res, next) {

	var er1, er2, er3, msg;
	er1=req.session.error1;
	er2=req.session.error2; 
	er3=req.session.error3;
	msg=req.session.message;
	delete req.session.error1; 
 	delete req.session.error2; 
 	delete req.session.error3;
  res.render('landingPage', { 
  	title: 'Express',
  	error1: er1,
  	error2: er2, 
  	error3: er3,
  	msg: msg,
  	user: req.user
  	}); 


});

router.get('/logout', function(req, res, next){
  req.logout();
  res.redirect('/');
});

/*GET create account. */

router.get('/createaccount', function (req, res, next) { //TODO---ADD Authentication Barrier (just to pass to page for navbar?)
	res.render('createAccount', {
		title: 'Success', 
		user: req.user
	});
});

router.post('/createaccount', db.createStudent); //TODO---ADD Authentication Barrier (not logged in, or logged in as housing staff)





router.get('/program/:programID', function(req, res, next) {
	res.json({
		message:"GET to /program/:programID",
		programID: programID
	});
});


router.get('/about', function (req, res, next) {
	res.json({
		message:"GET to /about"
	});	
});

router.get('/contact', function (req, res, next) {
	res.json({
		message:"GET to /contact"
	});	
});

router.get('/tour', function (req, res, next) {
	res.json({
		message:"GET to /tour"
	});	
});

module.exports = router;
