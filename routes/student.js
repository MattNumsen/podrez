var express = require('express');
var router = express.Router();

var db = require('../queries.js');
var authHelpers = require('../auth/_helper.js');
var auth = require('../auth/psprt.js');
var bcrypt = require('bcrypt');

var SALT_WORK_FACTOR = 10;

/*-------------------In This Document-------------------*/
/* Handle all calls to "server/students                 */
/*                                                      */
/* Functionally handles log in, accuont creation, view  */
/* profile                                              */
/*                                                      */
/* Stubs for pages such as Maintenance, Application,    */ 
/* Calendar, Equipment, Programs, CALENDAR             	*/
/*                                                      */
/* -----------------------------------------------------*/



/*-------------------------TODO-------------------------*/
/* Add put/post/delete for EQUIPMENT, MAINTENANCE 		*/
/*                                                      */ 
/* Populate Stubs                                       */
/* -----------------------------------------------------*/


router.get('/', function(req, res, next) {
	if (req.isAuthenticated() && req.user.role === 1){
		res.redirect('/students/profile');
	} else {
		res.redirect('..');
	}

});

router.post('/', function (req, res, next) {  	
	auth.passport.authenticate('student', function (error, user, info) {
    console.log(error, user, info);
    if (error) {
      // error
      	req.session.error1 = 'Incorrect username or password';
		res.redirect('/');;
    } else if (!user) {
      // unsuccesful login
      res.json({
        status: "User is Null",
        message: info.message
      });
    } else {
      // successful login
      req.login(user, function(err) {
        if (err) return next(err);

        console.log("Request Login As Student is Successful.");

        res.redirect('/students/profile');
      });
    }
  }) (req, res);
});

router.get('/profile/:id', auth.ensureStudentAuthenticated, db.getStudent); //TODO---ADD Authentication Barrier


router.get('/profile', function(req, res, next) {
	console.log("Get Profile" + req.session);
	if (req.isAuthenticated()){
		var redir = '/students/profile/' + req.user.username;
		console.log(req.user)
		res.redirect(redir);
	}
	else {
		res.redirect('/');
	}
});

router.get('/program', function (req, res, next) {
	res.json({
		message:"GET to /student/program"
	});	
});

router.get('/apply', function (req, res, next) {
	res.json({
		message:"GET to /student/apply"
	});	
});

router.get('/application-status', function (req, res, next) {
	res.json({
		message:"GET to /student/application-status"
	});	
});

router.get('/equipment', function (req, res, next) {
	res.json({
		message:"GET to /student/equipment"
	});	
});

router.get('/calendar', function (req, res, next) {
	res.json({
		message:"GET to /student/calendar"
	});	
});

router.get('/maintenance', function (req, res, next) {
	res.json({
		message:"GET to /student/maintenance"
	});	
});

module.exports = router;