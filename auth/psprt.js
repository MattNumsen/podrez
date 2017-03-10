const bcrypt = require('bcrypt');
var SALT_WORK_FACTOR = 10;

const passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
const authHelpers = require('./_helper.js');

var db = require("../initDB.js");

var options = {

};












//----------------------------------------------------------------//


/* Student Accont Authentication, called from logging in by post to /student (SUBJECT TO CHANGE) */
passport.use('student', new LocalStrategy(options, function (username, password, done) {
  //console.log("passport STUDENT " + username);
  // find the user
  	db.one('select * from studentAccount where sid = $1', username) 
  	.then(function (data) {
    	db.one('select * from podUser where podid = $1', data.podid)
	    .then(function (user) {
	   
	    // if user has been found
		    if (user) {
		      // validate their password against DB
		      	var result = bcrypt.compareSync(password, user.password)		      
		        if (result) {
					//console.log("passport: password correct");
					user.username = username;
					done(null, user, {
					message: 'Login successful!'
					});
		        } else {
					//console.log("passport: wrong password");
					done(null, false, {
					message: 'Your password does not match.'
					});
		        }		      
		    } else {
			// user does not exist
				//console.log("passport: user does not exist");
				done(null, null, {
					message: 'This user does not exist.'
				});
			}
		})
	  	.catch (function (err) {
	  		if (err) {
				//console.log("passport: Error finding PODID from SID");
				done(err);
	    	}
	  	});
	})
  	.catch (function (err) {
  		if (err) {
  			//console.log("passport: Error finding SIDs");
  			done(err);
  		}
  	});
}));



/* Reslife User Account Authentication, called from logging in by post to /reslife (SUBJECT TO CHANGE) */
passport.use('reslife', new LocalStrategy(options, function (username, password, done) {
  //console.log("passport RESLIFE " + username);
  // find the user
  	db.one('select * from reslifeAccount where resID = $1', username) 
  	.then(function (data) {
    	db.one('select * from podUser where podid = $1', data.podid)
	    .then(function (user) {
	   
	    // if user has been found
		    if (user) {
		      // validate their password against DB
		      	var result = bcrypt.compareSync(password, user.password) //not all passwords are encrypted yet		      
		        if (result) {
					//console.log("passport: password correct");
					user.username = username;
					done(null, user, {
					message: 'Login successful!'
					});
		        } else {
					//console.log("passport: wrong password");
					done(null, false, {
					message: 'Your password does not match.'
					});
		        }		      
		    } else {
			// user does not exist
				//console.log("passport: user does not exist");
				done(null, null, {
					message: 'This user does not exist.'
				});
			}
		})
	  	.catch (function (err) {
	  		if (err) {
				//console.log("passport: Error finding PODID from ResID");
				done(err);
	    	}
	  	});
	})
  	.catch (function (err) {
  		if (err) {
  			//console.log("passport: Error finding ResID");
  			done(err);
  		}
  	});
}));



/* Housing User Account Authentication, called from logging in by post to /housing (SUBJECT TO CHANGE) */
passport.use('housing', new LocalStrategy(options, function (username, password, done) {
  //console.log("passport HOUSING " + username);
  // find the user
  	db.one('select * from housingAccount where housingID = $1', username) 
  	.then(function (data) {
    	db.one('select * from podUser where podid = $1', data.podid)
	    .then(function (user) {
	   
	    // if user has been found
		    if (user) {
		      // validate their password against DB
		      	var result = bcrypt.compareSync(password, user.password) //not all passwords are encrypted yet		      
		        if (result) {
					//console.log("passport: password correct");
					user.username = username;
					done(null, user, {
					message: 'Login successful!'
					});
		        } else {
					//console.log("passport: wrong password");
					done(null, false, {
					message: 'Your password does not match.'
					});
		        }		      
		    } else {
			// user does not exist
				//console.log("passport: user does not exist");
				done(null, null, {
					message: 'This user does not exist.'
				});
			}
		})
	  	.catch (function (err) {
	  		if (err) {
				//console.log("passport: Error finding PODID from HousingID");
				done(err);
	    	}
	  	});
	})
  	.catch (function (err) {
  		if (err) {
  			//console.log("passport: Error finding HousingID");
  			done(err);
  		}
  	});
}));


/*-- The Serialization and Deserialization functions deal with PODUSERs, not Students/Reslife/Housing accounts directly.--*/
/*-- So long as each authentication strategies returns a poduser as the "user", this is fine. User schema contains a  	--*/
/*-- "role" variable (check with req.user.role) which indicates the account type in use.  								--*/
/*-- req.user.role === 1 -> Student --*/
/*-- req.user.role === 2 -> Reslife --*/
/*-- req.user.role === 3 -> Housing --*/
/*-- req.user.role === 99 -> System Administrator (if needed) --*/
/*-- --*/
// store session
passport.serializeUser(function(user, done) {
	//console.log("In Serialize");
	//console.log(user);
  done(null, user);
});


passport.deserializeUser(function(userbase, done){
    //find a user
    db.one('select * from podUser where podid=$1', userbase.podid)
    .then(function(user) { 
    		user.username = userbase.username;

    		done (null, user); 
    })
    .catch(function(err) 
	{ 
		done(err, null); 
	});
});

function ensureStudentAuthenticated(req, res, next) {   
	//console.log('Student Authenticate?', req.isAuthenticated());   
	if (req.isAuthenticated()) {     
		if (req.user.role === 1) {
			return next();   
		}
	} else {     
		if (req.method === "POST") {       
		res.json({         
			status: "fail",         
			message: "User is not authenticated."       
			});     
		} else if (req.method === "GET") {       
			res.redirect('/');     
		}   
	} 
}

function ensureReslifeAuthenticated(req, res, next) {   
	//console.log('Reslife Authenticate?', req.isAuthenticated());   
	if (req.isAuthenticated()) {     
		if (req.user.role === 2) {
			return next();   
		}
	} else {     
		if (req.method === "POST") {       
		res.json({         
			status: "fail",         
			message: "User is not authenticated."       
			});     
		} else if (req.method === "GET") {       
			res.redirect('/');     
		}   
	} 
}

function ensureHousingAuthenticated(req, res, next) {   
	//console.log('Housing Authenticate?', req.isAuthenticated());   
	if (req.isAuthenticated()) {     
		if (req.user.role === 2) {
			return next();   
		}
	} else {     
		if (req.method === "POST") {       
		res.json({         
			status: "fail",         
			message: "User is not authenticated."       
			});     
		} else if (req.method === "GET") {       
			res.redirect('/');     
		}   
	} 
}




module.exports = {
	passport,
	ensureStudentAuthenticated, 
	ensureReslifeAuthenticated,
	ensureHousingAuthenticated
};

