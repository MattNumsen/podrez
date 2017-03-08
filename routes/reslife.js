var express = require('express');
var router = express.Router();

var db = require('../queries.js');
var authHelpers = require('../auth/_helper.js');
var auth = require('../auth/psprt.js');
var bcrypt = require('bcrypt');

var SALT_WORK_FACTOR = 10;


/*-------------------In This Document-------------------*/
/* Handle all calls to "server/reslife"                 */
/*                                                      */
/* Functionally handles log in, program creation, view  */
/* profile                                              */
/*                                                      */
/* Stubs for pages such as Maintenance, Incidents,      */ 
/* Calendar Equipment,  and Programs                    */
/*                                                      */
/* -----------------------------------------------------*/


/*-------------------------TODO-------------------------*/
/* Add put/post/delete for INCIDENT, EQUIPMENT, MAINT   */
/*                                                      */ 
/* Add route for creation of other reslife accounts by  */
/* reslife admin account                                */
/*                                                      */
/* Populate Stubs                                       */
/* -----------------------------------------------------*/

router.get('/', function(req, res, next) {
	if (req.isAuthenticated() && req.user.role === 2){
		res.redirect('/reslife/profile');
	} else {
		res.redirect('..');
	}

});

router.post('/', function (req, res, next) {  	
	auth.passport.authenticate('reslife', function (error, user, info) {
    console.log(error, user, info);
    if (error) {
      // error
      	req.session.error2 = 'Incorrect username or password';
		res.redirect('/');

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

        console.log("Request Login As Reslife is successful.");

        res.redirect('/reslife/profile');
      });
    }
  }) (req, res);
});


router.get('/profile', function(req, res, next) {
	console.log("Get Profile" + req.user);
	if (req.isAuthenticated()){
		res.redirect('/reslife/createProgram');
	}
	else {
		res.redirect('/');
	}
});


router.get('/createProgram', auth.ensureReslifeAuthenticated, db.programProposal); 
router.post('/createProgram', auth.ensureReslifeAuthenticated, db.programSubmission); 
router.get('/programs', auth.ensureReslifeAuthenticated, db.getAllPrograms);

router.get('/program/:programID', auth.ensureReslifeAuthenticated, db.getProgram);


router.get('/viewStudent/:studID', function (req, res, next) {
  res.json({
    message:"GET to /reslife/viewStudent/studID",
    studID: req.params.studID
  }); 
});

router.get('/viewStudents/', auth.ensureReslifeAuthenticated, db.getAllStudents);


router.get('/submitIncident', function (req, res, next) {
  res.json({
    message:"GET to /reslife/submitIncident"
  }); 
});
router.post('/submitIncident', function (req, res, next) {
  res.json({
    message:"POST to /reslife/submitIncident"
  }); 
});

router.get('/incidents/', function (req, res, next) {
  res.render('viewAllIncidents', {
    user: req.user
  })
});

router.get('/incident/:incidentID', function (req, res, next) {
  res.json({
    message:"GET to /reslife/incident/incidentID", 
    incidentID: incidentID
  }); 
});

router.get('/equipment', function (req, res, next) {
  res.json({
    message:"GET to /reslife/equipment"
  }); 
});

router.get('/maintenance', function (req, res, next) {
  res.json({
    message:"GET to /reslife/Maintenance"
  }); 
});

module.exports = router;