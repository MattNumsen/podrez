var express = require('express');
var router = express.Router();

var db = require('../queries.js');
var authHelpers = require('../auth/_helper.js');
var auth = require('../auth/psprt.js');
var bcrypt = require('bcrypt');

var SALT_WORK_FACTOR = 10;


/*-------------------In This Document-------------------*/
/* Handle all calls to "server/housing"					*/
/* 														*/
/* Functionally handles log in, and sofar nothing else 	*/
/* 														*/
/* Stubs for pages such as Application, Maintenance, 	*/
/* Equipment, Rooms, Buildings, Studnets and Programs	*/
/* -----------------------------------------------------*/


/*-------------------------TODO-------------------------*/
/* Determine effective routing for GUSEST attendance	*/
/* 														*/
/* Add put/post/delete for ROOM, BUILDING, EQUIPMENT	*/
/* STUDENT, APPLICATION 								*/
/*														*/ 
/* Add route for creation of other housing accounts by 	*/
/* housing admin account								*/
/*                                                      */
/* Populate Stubs                                       */
/* -----------------------------------------------------*/


router.get('/', function(req, res, next) {
	if (req.isAuthenticated() && req.user.role === 3){
		res.redirect('/housing/profile');
	} else {
		res.redirect('..');
	}

});

router.post('/', function (req, res, next) {  	
	auth.passport.authenticate('housing', function (error, user, info) {
    console.log(error, user, info);
    if (error) {
      // error
      	req.session.error3 = 'Incorrect username or password';
		res.redirect('/');
    } else if (!user) {
      // unsuccesful login
      res.json({
        status: "Housing User Is Null",
        message: info.message
      });
    } else {
      // successful login
      req.login(user, function(err) {
        if (err) return next(err);

        console.log("Request Login As Housing is Successful.");

        res.redirect('/housing/profile');
      });
    }
  }) (req, res);
});

router.get('/profile', function(req, res, next) {
	console.log("Get Profile" + req.user);
	if (req.isAuthenticated()){
		res.json({
        status: "Housing Profile Go Here",
      });
	}
	else {
		res.redirect('/');
	}
});


router.get('/application/:applicationID', function (req, res, next) {
  res.json({
    message:"GET to /housing/applications/:applicationID",
    applicationID: applicationID
  }); 
});

router.put('/application/:applicationID', function (req, res, next) {
  res.json({
    message:"PUT to /housing/application/:applicationID - TO BE USED FOR UPDATING STATUS OF APPLICATION",
    applicationID: applicationID
  }); 
});

router.get('/applications', function (req, res, next) {
  res.json({
    message:"GET to /housing/applications"
  }); 
});




router.get('/viewStudent/:studID', function (req, res, next) {
  res.json({
    message:"GET to /housing/viewStudent/studID",
    studID: studID
  }); 
});

router.get('/rooms', function (req, res, next) {
  res.json({
    message:"GET to /housing/rooms"
  }); 
});

router.get('/room/:roomID', function (req, res, next) {
  res.json({
    message:"GET to /housing/room/roomID",
    roomID: roomID
  }); 
});

router.get('/buildings', function (req, res, next) {
  res.json({
    message:"GET to /housing/buildings"
  }); 
});

router.get('/building/:buildingID', function (req, res, next) {
  res.json({
    message:"GET to /housing/building/buildingID", 
    buildingID: buildingID
  }); 
});

router.get('/maintenance', function (req, res, next) {
  res.json({
    message:"GET to /housing/maintenance"
  }); 
});

router.get('/maintenance/:maintenanceID', function (req, res, next) {
  res.json({
    message:"GET to /housing/maintenance/maintenanceID",
    maintenanceID: maintenanceID
  }); 
});

router.get('/equipment', function (req, res, next) {
  res.json({
    message:"GET to /housing/equipment"
  }); 
});


router.get('/equipment/:eqID', function (req, res, next) {
  res.json({
    message:"GET to /housing/equipment/eqID",
    eqID: eqID
  }); 
});

router.get('/programs', function (req, res, next) {
  res.json({
    message:"GET to /housing/programs"
  }); 
});

router.get('/program/:programID', function (req, res, next) {
  res.json({
    message:"GET to /housing/program/programID", 
    programID: programID
  }); 
});





module.exports = router;