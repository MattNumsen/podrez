var db = require("./initDB.js");

var Promise = require('bluebird');
var moment=require('moment');
moment().format();
var options = {
  // global event notification;
    error: function (error, e) {
        if (e.cn) {
            // A connection-related error;
            //
            // Connections are reported back with the password hashed,
            // for safe errors logging, without exposing passwords.
            console.log("CN:", e.cn);
            console.log("EVENT:", error.message || error);
        }
    },
  promiseLib: Promise
};

var pgp = require('pg-promise')(options);
var PQ = require('pg-promise').ParameterizedQuery;

var bcrypt = require('bcrypt');

var SALT_WORK_FACTOR = 10;
// add query functions
db.connect()
    .then(function (obj) {
        obj.done(); // success, release the connection;
    })
    .catch(function (err) {
        console.log("ERROR:", err.message || err);
    });



/*-----------------------------------------

TODO:
perhaps include a DB entity with the information for each semesters intended questionaire information?
could have a form for housing admin to input as many different questions as they'd like, 
and then store those parameters as a JSON, which then is used by a templater to auto generate the form for them?

neat potential. 

-----------------------------------------*/

function applicationForm (req, res, next) {
	var err = req.session.err;
	var suc = req.session.suc;
	delete req.session.err;
	delete req.session.suc;
	db.task(function(t) {
		var buildingQ = t.many('select buildingID, description from building');
		var studentQ = t.one('select * from studentAccount where podID=$1', req.user.podid);
		var semesterQ =  t.many('select * from semester');
		return Promise.all([buildingQ, studentQ, semesterQ]).spread(function(buildings, student, semesters){
			res.render('ApplicationForm', {
				user: req.user, 
				title: 'Submit Application', 
				building_list: buildings, 
				current_user: student, 
				semester_list: semesters, 
				err: err,
				suc: suc
			});
		})
	})	
	.catch (function(err) {
		return next(err);
	});
}
function submitApplication (req, res, next) {


	var submitted = new Date(Date.now());

	db.task(function(t){
		return t.one('select sid from studentAccount where podid = $1', req.user.podid).then(function(student){
			return t.oneOrNone('SELECT sid, semcode from application where sid = $1 and semcode = $2', [student.sid, req.body.semcode]).then(function(record){
				if (student.sid != req.body.sid) { 
					req.session.err="You just tried to submit an application for someone else. How did you do that?"
					res.redirect('/students/apply');
				} else if (record == null){
					return t.none('INSERT INTO application (sid, semcode, submitted, info) VALUES ($1, $2, $3, $4)', [student.sid, req.body.semcode, submitted, req.body]).then(function(){
						req.session.suc="You just applied for residence! Thanks!";
						res.redirect('/students/apply');
					});
				} else {
					req.session.err = "You've already submitted an Application for that semester, but thanks for being so excited!";
					res.redirect('/students/apply');
				}
			})		
		})
	})
	.catch(function(err) {
		return next(err);
	});
}
function getMaintenanceForm(req, res, next) {
	var error = req.session.err;
	var suc = req.session.suc;
	var maintid = req.params.maintenanceid;
	if (maintid == null) {
		maintid = 0;
	}
	delete req.session.err;
	delete req.session.suc;
	db.task(function(t) {
		var buildingQ =  t.many('select * from building');
		var studentQ = t.one('select * from studentAccount where podid=$1', req.user.podid);
		var roomQ = t.many('select buildingid, roomid from room');
		var maintreqQ = t.oneOrNone('select maintid, podid, roomid, buildingid, info from maintrequest where maintid = $1', maintid);

		return Promise.all([buildingQ, studentQ, roomQ, maintreqQ]).spread(function(buildings, student, rooms, maintreq){
			res.render('maintenanceForm', {
				user: req.user, 
				branch: req.session.branch,
				current_user: student,
				building_list: buildings, 
				room_list: rooms,
				err: error,
				suc: suc, 
				maintreq: maintreq,
				title: 'Submit Maintenance Request'
			});
		})
	})
	.catch(function(err) {
		return next(err);
	})
}
function postMaintenanceForm(req, res, next) {
	var submitted = new Date(Date.now());
	//TODO Verify given roomID and buildingID

	req.body.room=JSON.parse(req.body.room);
	console.log(req.body.room);
	console.log(req.body);
	console.log(req.body.building);

	db.one('select sid from studentAccount where podid = $1', req.user.podid)
	.then(function(student){
		if (student.sid != req.body.sid) {
			req.session.err="You just tried to submit information as someone else. How did you do that?";
			res.redirect('/students/maintenance');
		} else {
			if (req.body.room == 0) {
				db.none('insert into maintrequest (podid, buildingid, submitted, info) VALUES ($1, $2, $3, $4)', [req.user.podid, req.body.building, submitted, req.body])
				.then(function() {
					req.session.suc="Thanks for letting us know, we'll get to it promptly";
					res.redirect('../maintenance/submit')
				})	
			} else {
				db.none('insert into maintrequest (podid, buildingid, roomid, submitted, info) VALUES ($1, $2, $3, $4, $5)', [req.user.podid, req.body.room.buildid, req.body.room.roomid, submitted, req.body])
				.then(function() {
					req.session.suc="Thanks for letting us know, we'll get to it promptly";
					res.redirect('../maintenance/submit')
				})
			}
		}
	})
	.catch(function(err) {
		return next(err);
	});
}
function getSubmittedMaintenance(req, res, next){
	//get all the maintenance requests which were submitted by the current user
	db.manyOrNone('SELECT * from maintrequest where podid = $1', req.user.podid)
	.then(function(maintlist){
		res.render('viewAllMaintenance', {
			branch: req.session.branch, 
			user: req.user, 
			title: 'View Maintenance Requests',
			maintlist: maintlist 
		})
	})
	.catch(function(err) {
		return next(err);
	})
}
function updateMaintenance(req, res, next){
	var maintid = req.params.maintenanceid;
	req.body.room=JSON.parse(req.body.room);
	db.task(function(t){
		if (req.body.room == 0) {
			return t.none('update maintrequest set (buildingid, info) = ($1, $2) where maintid = $3', [req.body.building, req.body, maintid]);
		} else {
			return t.none('update maintrequest set (buildingid, roomid, info) = ($1, $2, $3) where maintid = $4', [req.body.room.buildid, req.body.room.roomid, req.body, maintid]);
		}
	})
	.then(function() {
		req.session.suc="Thanks for letting us know, we'll get to it promptly";
		res.redirect('../maintenance/submit');
	})
	.catch(function(err) {
		return next(err);
	});
}
function deleteMaintenance(req, res, next){
	db.none('delete from maintrequest where maintid = $1', req.params.maintenanceid)
	.then(function(){
		req.session.suc="Thanks for taking that work off our plate!";
		res.redirect('../submit');
	})
	.catch(function(err) {
		return next(err);
	})

}



function incidentCreationForm(req, res, next) {
	//What do we need for the form? List of all students (with agreements) NAMES and STUDENT IDs
	//list of all other CAs and ACs and RLCs names (and IDs?)
	//list of all available rooms and buildings 
	//contract when imported
	//three different objects. stud_list, res_list and room_list. 

	db.task(function(t) {
		var studentsQ =  t.many('select firstname, lastname, sid from studentAccount')
		var reslifeQ = t.many('select firstname, lastname, resid, permission from reslifeAccount')
		var roomlistQ =  t.many('select roomID, room.buildingID, description from room, building where room.buildingID = building.buildingID')
		Promise.all([studentsQ, reslifeQ, roomlistQ]).spread(function(stud_list, res_list, room_list){
			res.render('createIncidentReport', {
				stud_list: stud_list, 
				res_list: res_list, 
				room_list: room_list, 
				user: req.user, 
				title: 'Create Incident'
			});
		})
	})
	.catch(function(err) {
		return next(err);
	});
}
function programSubmission(req, res, next) {
	
	
	/*
		In a program submission, we need to do a few things
		#1: Create a "Program" entry in the programs table
		#2: Create a "program_account" entry for EACH COLLABORATOR and (once user authentication exists) THE USER CREATING THE PROGRAM

	*/

	var pass=req.body;
	var count=req.body.collabCount;
	var regex = /^([0-9]+):([0-9]+) ([a-zA-Z]+)$/
	var submitted = moment();
	var planned = moment(req.body.date);
	var result = req.body.time.match(regex);
	var hours=parseInt(result[1]);
	var minutes=parseInt(result[2]);

	if (result[3] == "PM"){
		hours = hours + 12;
	}

	//Self Discussion area
	//Should I use a Promise.all().spread() type format here?
	//Why do we use it in the first place? To get results from multiple promises all in one handy area
	//do I need data from multiple sources here? No. I need to insert a bunch of stuff, which i should figure out how to BATCH
	//From that point on, all i need to do is set a success message, and redirect to wherever makes sense. 
	//Currently, i am handling the insertions as part of a TRANSACTION, which is appropriate because if one fails, the whole operation is rolled back
	//so, data integrity is there at least. 
	//I think the only thing I *should* consider changing, is the for loop which inserts multiple account_program records
	//I just need to read up on the batching a bit more and see if it makes sense to use it as values (static_value, changeseverytime)...
  //TODO: Read up on BATCH in pg-promise API

	var event_date = moment(planned).add(hours, 'hours').add(minutes, 'minutes');
	db.tx(function(t) {
		return t.one('select resID from reslifeAccount where podID = $1', req.user.podid)
		.then(function(resdata) {
      return t.one('INSERT INTO program(info, resid_owner, resid_creater, submitted, event_date, podid) VALUES($1, $2, $2, $3, $4, $5) RETURNING programid', [pass, resdata.resid, submitted, event_date, req.user.podid])
      .then(function (program) {
      	if (count == 1){
      		t.none('INSERT INTO account_program(programID, resID) VALUES($1, $2)', [program.programid, req.body.collaborators]);
      	} else {
        	for (i=0; i < count; i++){
        		t.none('INSERT INTO account_program(programID, resID) VALUES($1, $2)', [program.programid, req.body.collaborators[i] ]);
        	} 
        }
        t.none('INSERT INTO account_program(programID, resID) VALUES($1, $2)', [program.programid, resdata.resid]); 
      });
		});
	})
	.then(function() {
      res.render('landingPage', { //TODO: ADD A SUCCESS BOX TO THE PROGRAM SUBMISSION FORM, AND REDIRECT THERE
      	user: req.user 
      });
  })
  .catch(function(err) {
      return next(err);
  });
}
function createStudent(req, res, next) {
		
	var salt = bcrypt.genSaltSync();
  var hash = bcrypt.hashSync(req.body.password, salt);
	var birthdate = new Date(req.body.date);
	var ageDifMs = Date.now() - birthdate.getTime();
  var ageDate = new Date(ageDifMs); // miliseconds from epoch
  var age = Math.abs(ageDate.getUTCFullYear() - 1970);
  var pass = req.body;

  pass.age = age;
  pass.date = birthdate;
  pass.password = hash;

  db.oneOrNone('select insert_student(${fname}, ${lname}, ${midname}, ${sid}, ${password}, ${age}, ${date}, ${gender})', pass)  
	.then(function () {
		res.render('landingPage', {
    	user: req.user
    });
	})
  .catch(function(err) {
      return next(err);
  });
}
function getAllStudents(req, res, next) {
	db.any(`
		SELECT stud.sid, stud.firstname, stud.lastname, bui.description, agr.roomID 
		FROM studentAccount stud 
		JOIN application app ON app.sid = stud.sid
		JOIN agreement agr ON app.applicationid=agr.applicationid
		JOIN building bui ON agr.buildingID=bui.buildingID
	`)
	.then(function(data) {
		res.render('viewAllStudents', {
			student_info: data, //sid, firstname, lastname, description, roomID
			user: req.user, 
			title: "View All Students"
		});
	})
	.catch(function (err) {
		return next(err);
	});
}
function getStudent(req, res, next) { 
	var studID = parseInt(req.params.studID);
	//things we want: Agreement information, Application information, Attending information
	db.task(function(t){
		return t.one('select * from studentAccount where sid=$1', studID).then(function(student){
			var resQ = t.oneOrNone(`	
				SELECT agr.roomid, agr.buildingid, bui.description 
				FROM agreement agr, application app , building bui
				WHERE app.sid = $1 AND 
				agr.applicationid = app.applicationid AND 
				app.semcode=1 AND 
				bui.buildingid = agr.buildingid`, student.sid);
			var newProgramQ = t.manyOrNone(`	
				SELECT res.firstname, res.lastname, pro.programid, pro.event_date, pro.info from program pro
				JOIN attending att on att.podid=$1 and att.programid=pro.programid
				JOIN reslifeAccount res on pro.resid_creater=res.resid
				WHERE pro.event_date > current_timestamp
				ORDER by pro.event_date
				LIMIT 4;`, student.podid);
			var oldProgramQ = t.manyOrNone(`	
				SELECT res.firstname, res.lastname, pro.programid, pro.event_date, pro.info from program pro
				JOIN attending att on att.podid=$1 and att.programid=pro.programid
				JOIN reslifeAccount res on pro.resid_creater=res.resid
				WHERE pro.event_date < current_timestamp
				ORDER by pro.event_date DESC
				LIMIT 4;`, student.podid);
			if((req.user.role == 1) && (student.podid !=req.user.podid)) { 
				req.session.message="You don't have permission to view this profile"
			}

			return Promise.all([resQ, newProgramQ, oldProgramQ]).spread(function(resinfo, prolist, oldprolist){

				if((req.user.role == 1) && (student.podid != req.user.podid)) { 
					req.session.message="You don't have permission to view this profile"
					res.redirect('/');
				} else {
					res.render('studentProfile', {
						user: req.user, 
						resinfo: resinfo, 
						prolist: prolist,
						student: student,
						branch: req.session.branch,
						oldprolist: oldprolist, 
						title: "Profile View"
					});
				}
			})
		})
	}).catch(function(err){
		return next(err);
	})
}
function getAllPrograms(req, res, next) {
	db.many(`	
		SELECT prog.programID AS progID, prog.info AS info, prog.submitted AS submitted, prog.event_date AS event_date, res1.firstName AS creatorFName, res1.lastName AS creatorLName, res2.firstName AS ownerFName, res2.lastName AS ownerLName 
		FROM program prog, reslifeAccount res1, reslifeAccount res2
		WHERE prog.resid_owner = res1.resID
		AND prog.resid_creater = res2.resID`)
	.then(function (programs)  {
		res.render('viewAllPrograms', {
			user: req.user, 
			program_info:programs,
			branch: req.session.branch, 
			title: "View All Programs"
		});
	})
}

function programProposal(req, res, next) {

	db.task(function(t){
		var resQ = t.many('select * from reslifeAccount')
		var buildingQ = t.many('select * from building')
		return Promise.all([resQ, buildingQ]).spread(function(resUser, buildings){
			res.render('createProgram', {
				resUser: resUser,
				buildings: buildings, 
				user: req.user, 
				title: "Propose a Program"
			});
		})
	})
	.catch(function (err) {
		return next(err);
	});
}

function updateStudent(req, res, next) {
	req.body.age = parseInt(req.body.age);
	req.body.SID = parseInt(req.body.SID);
	db.none('update studentAccount set firstName=$1, lastName=$2, preferredName=$3, SID=$4, age=$5, birthdate=$6, gender=$7 where podid=$8',[req.body.firstName, req.body.lastName, req.body.preferredName, parseInt(req.body.SID), parseInt(req.body.age), req.body.birthdate, req.body.gender, req.params.id])
	.then(function () {
		res.status(200)
		.json({
			status: 'success', 
			message: 'updated student'
		});
	})
	.catch(function (err) {
		return next(err);
	});
}
function deleteStudent(req, res, next) {
	var id = parseInt(req.params.id);
	db.result('select delete_studentAccount($1)', id)
	.then(function(result){
		res.status(200)
		.json({
			status: 'success', 
			message: `deleted ${result.rowCount} student`
		});
	})
	.catch(function (err) {
		return next(err);
	});
}
function getProgram(req, res, next) {
	db.task(function(t){
		var programQ = t.one('select * from program where programID = $1', req.params.programID);
		var buildingQ = t.many('select * from building');
		var attendingQ = t.oneOrNone('select * from attending where (programID = $1 and podID = $2)', [req.params.programID, req.user.podid]);

		return Promise.all([programQ, buildingQ, attendingQ]).spread(function(program, attending, building){
			res.render('viewProgram', {
				user: req.user, //contains podID of current user
				program: program, //program.podID is CREATER, for use to display "editting" function -- may change to include RES_ID in user for res users for easier identification
				attending: attending, 
				building: building,
				branch: req.session.branch, 
				title: "View Program"
			});	
		})
	})
	.catch(function(err){
		return next(err);
	});
}
function getEQform1(req, res, next) {
	var error = req.session.err;
	var start_date = req.session.start_date;
	var end_date = req.session.end_date;
	delete req.session.err;
	delete req.session.start_date;
	delete req.session.end_date;

	if (start_date == null) { //need a date
		res.render('equipmentFormFirstView', {
			user: req.user, 
			err: error,
			branch: req.session.branch,
			title: "Equipment Rental - Pick a Date"
		});
	} else { //render the second form and remember your dates!
		db.many(`
			SELECT eq.eqid, eq.info FROM rentalAgreement rent
			JOIN equipment_rentalAgreement eqrent
				ON rent.eqrentalid = eqrent.eqrentalid
				AND ((rent.rental_start_date, rent.rental_end_date) OVERLAPS($1, $2) = 't')
				AND rent.status NOT IN (4, 6)
			RIGHT JOIN equipment eq
				ON eqrent.eqid = eq.eqid
			WHERE eqrent.eqid is NULL;
		`, [start_date, end_date])
		.then(function(eqlist){
			req.session.start_date = start_date;
			req.session.end_date = end_date;
			res.render('equipmentFormSecondView', { 
				user: req.user, 
				err: error,
				eqlist: eqlist,
				branch: req.session.branch,
				start_date: start_date, 
				end_date: end_date, 
				title: "Equipment Rental - Pick Equipment"
			});
		})
		.catch(function(err) {
			return next(err);
		});
	}
}
function postEQform1(req, res, next) {
	var start_date = moment(req.body.start_date);
	var end_date = moment(req.body.end_date);
	var range = end_date.diff(start_date, 'days');
	if (range < 0) {
		req.session.err="You picked the dates in the wrong order"
	} else if (range > 5) {
		req.session.err="Sorry, we don't rent anything out longer than 5 days"
	} else {
		//get all UNBOOKED equipment, and move to the next page
		req.session.start_date = start_date;
		req.session.end_date = end_date;
	}
	res.redirect('../equipment');
}

function postEQform2(req, res, next) {
	var now = new Date(Date.now());

	db.tx(function(t){
		return t.one(`
			INSERT INTO rentalAgreement (podid, status, rental_start_date, rental_end_date, submitted, updated)
			VALUES
			($1, 0, $2, $3, $4, $4) 
			RETURNING eqrentalid
			`, [req.user.podid, req.session.start_date, req.session.end_date, now])
		.then(function(data){
			if (req.body.equipCount == 1) {

				t.none('INSERT INTO equipment_rentalAgreement (eqrentalid, status, eqid) VALUES ($1, 0, $2)', [data.eqrentalid, req.body.equipment]);
			} else {
				for (i=0; i<req.body.equipCount; i++) {
					t.none('INSERT INTO equipment_rentalAgreement (eqrentalid, status, eqid) VALUES ($1, 0, $2)', [data.eqrentalid, req.body.equipment[i]]);
				}
			}
		})
	})
	.then(function(){
		req.session.message="success";
		res.redirect('../equipment');
	})
	.catch(function(err){
		return next(err);
	})
}

module.exports = {
	postEQform2: postEQform2,
	postEQform1: postEQform1,
	getEQform1: getEQform1,

	getSubmittedMaintenance: getSubmittedMaintenance,
	updateMaintenance: updateMaintenance,
	deleteMaintenance: deleteMaintenance,
	getMaintenanceForm: getMaintenanceForm,
	postMaintenanceForm: postMaintenanceForm,

	applicationForm: applicationForm,
	submitApplication: submitApplication,
	incidentCreationForm: incidentCreationForm,
	getAllPrograms: getAllPrograms,
	getProgram: getProgram,
	programSubmission: programSubmission, 
	programProposal: programProposal,
	getStudent: getStudent,
	getAllStudents: getAllStudents,
	createStudent: createStudent,
	updateStudent: updateStudent,
	deleteStudent: deleteStudent
};
