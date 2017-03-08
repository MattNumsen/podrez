var db = require("./initDB.js");

var promise = require('bluebird');

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
  promiseLib: promise
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
    .catch(function (error) {
        console.log("ERROR:", error.message || error);
    });

function programSubmission(req, res, next) {
	
	
	/*
		In a program submission, we need to do a few things
		#1: Create a "Program" entry in the programs table
		#2: Create a "program_account" entry for EACH COLLABORATOR and (once user authentication exists) THE USER CREATING THE PROGRAM

	*/

	var pass=req.body;
	var count=req.body.collabCount;
	var submitted = new Date(Date.now());
	db.one('select resID from reslifeAccount where podID = $1', req.user.podid)
	.then(function(resdata) {
		db.tx(function(t) {
	        // t = this
	        // t.ctx = transaction context object
	        return t.one('INSERT INTO program(info, resid_owner, resid_creater, submitted, podid) VALUES($1, $2, $2, $3, $4) RETURNING programid', [pass, resdata.resid, submitted, req.user.podid])
	            .then(function (program) {
	            	if (count == 1){
	            		t.none('INSERT INTO account_program(programID, resID) VALUES($1, $2)', [program.programid, req.body.collaborators]);
	            	} else {
		            	for (i=0; i < count; i++){
		            		console.log(req.body.collaborators[i]);
		            		t.none('INSERT INTO account_program(programID, resID) VALUES($1, $2)', [program.programid, req.body.collaborators[i] ]);
		            	} 
		            }
		            t.none('INSERT INTO account_program(programID, resID) VALUES($1, $2)', [program.programid, resdata.resid]); 
	            });
	    })
	    .then(function(data) {
	        // success
	        res.render('landingPage', { //TODO: ADD A SUCCESS BOX TO THE PROGRAM SUBMISSION FORM, AND REDIRECT THERE
	        	user: req.user 
	        });
	        // data = as returned from the transaction's callback
	    })
	    .catch(function(err) {
	        // error
	        return next(err);
	    });
	})
	.catch(function(err) {
		return next(err);
	});
}
function createStudent(req, res, next) {
	
	console.log(req.body);
	
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
    console.log(pass);
    db.oneOrNone('select insert_student(${fname}, ${lname}, ${midname}, ${sid}, ${password}, ${age}, ${date}, ${gender})', pass)
    //db.oneOrNone('select insert_student(${fname}, ${lname}, ${fname}, ${sid}, ${age}, ${date}, ${gender})', pass)
	//db.func(insert_student, [req.body.fname, req.body.lname, req.body.fname, parseInt(req.body.sid), parseInt(age), req.body.date, req.body.gender])
	
	.then(function () {
		res.render('landingPage', {
        	user: req.user
        });
	})
    .catch(function(err) {
        // error
        return next(err);
    });
	//	db.oneOrNone('select insert_student(${firstName}, ${lastName}, ${preferredName}, ${SID}, ${age}, ${birthdate}, ${gender})', req.body)
	
}
/*  example: 	curl --data "firstName=testing&lastName=TESTING&preferredName=Tested&SID=123456789&age=22&date=1993-05-28&gender=M" \
				http://127.0.0.1:3000/test/students */



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
	var studID = parseInt(req.params.id);
	db.one('select * from studentAccount where sid = $1', studID)
	.then(function(data) {
		console.log("inside Get Student");
		console.log (req.user);
		res.render('studentProfile', {
				studAccount: data, 
				user: req.user, 
				title: "View Student" 
			});
	})
	.catch(function (err) {
		return next(err);
	});
}


function getAllPrograms(req, res, next) {

	db.many(`	SELECT prog.programID AS progID, prog.info AS info, prog.submitted AS submitted, res1.firstName AS creatorFName, res1.lastName AS creatorLName, res2.firstName AS ownerFName, res2.lastName AS ownerLName 
				FROM program prog, reslifeAccount res1, reslifeAccount res2
				WHERE prog.resid_owner = res1.resID
				AND prog.resid_creater = res2.resID 
			`) //data = progID, info, submitted, creatorFName, creatorLName, ownerFName, ownerLName
	.then(function (data)  {
		res.render('viewAllPrograms', {
			user: req.user, 
			program_info:data, 
			title: "View All Programs"
		});
	})
}


function programProposal(req, res, next) {
	
	var reslifeUser = [];
	db.many('select * from reslifeAccount')
	.then(function (data1) {
		reslifeUser=data1;
		db.many('select * from building')
		.then(function(data2){
			console.log(data2);
			res.render('createProgram', {
				resUser: reslifeUser,
				buildings: data2, 
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
	programID = req.params.programID;
	db.one('select * from program where programID = $1', programID)
	.then(function(program) {
		var podid;
		if (req.isAuthenticated()) {
			podid=req.user.podid;
		} 

		db.many('select * from building')
		.then(function(building) {

			db.oneOrNone('select * from attending where (programID = $1 and podID = $2)', [program.programid, podid])
			.then(function(attending) {

				res.render('viewProgram', {
					user: req.user, //contains podID of current user
					program: program, //program.podID is CREATER, for use to display "editting" function -- may change to include RES_ID in user for res users for easier identification
					attending: attending, 
					building: building, 
					title: "View Program"
				});
			})
			.catch(function(err){
				return next(err);
			})
		})
		.catch(function(err){
			return next(err);
		})
	})
	.catch(function(err){
		return next(err);
	});
}

module.exports = {
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
