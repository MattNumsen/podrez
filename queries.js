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
var connectionString = 'postgres://matt:password@localhost:5432/podrez';
var db = pgp(connectionString);

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
	console.log(count);
	console.log(req.body.collaborators[0]);
	console.log(req.body.collaborators[1]);


	db.tx(function(t) {
        // t = this
        // t.ctx = transaction context object

        return t.one('INSERT INTO program(info) VALUES(${this}) RETURNING programid', pass)
            .then(program=> {
            
            	for (i=0; i < count; i++){
            		console.log(req.body.collaborators[i]);
            		t.none('INSERT INTO account_program(programID, resID) VALUES($1, $2)', [program.programid, req.body.collaborators[i] ]);
            	}  
            });
    })
    .then(function(data) {
        // success
        res.render('landingPage');
        // data = as returned from the transaction's callback
    })
    .catch(function(error) {
        // error
        return next(err);
    });


}

function getAllStudents(req, res, next) {
	db.any('select * from studentAccount')
		.then(function(data) {
			res.status(200)
				.json({
					status: 'success', 
					data:data, 
					message: 'Retrieved ALL students'
				});		
		})
		.catch(function (err) {
			return next(err);
		});
}


function getStudent(req, res, next) {
	var studID = parseInt(req.params.id);
	db.one('select * from studentAccount where podID = $1', studID)
	.then(function(data) {
		res.render('studentProfile', {
				studAccount: data 
			});
	})
	.catch(function (err) {
		return next(err);
	});
}

function programProposal(req, res, next) {
	
	var reslifeUser = [];
	db.many('select * from reslifeAccount')
	.then(function (data1) {
		reslifeUser=data1;
		db.many('select * from building')
		.then(function(data2){
			console.log(data2);
			res.render('temp2', {
				resUser: reslifeUser,
				buildings: data2
			});
		})
		
	})
	.catch(function (err) {
		return next(err);
	});
}

function createStudent(req, res, next) {
	req.body.age = parseInt(req.body.age);
	req.body.SID = parseInt(req.body.SID);
	db.oneOrNone('select insert_student(${firstName}, ${lastName}, ${preferredName}, ${SID}, ${age}, ${birthdate}, ${gender})', req.body)
	.then(function () {
		res.status(200)
		.json({
			status: 'success', 
			message: 'inserted ONE student'
		});
	})
	.catch(function (err) {
		return next(err);
	});
}
/*  example: 	curl --data "firstName=testing&lastName=TESTING&preferredName=Tested&SID=123456789&age=22&birthdate=1993-05-28&gender=M" \
				http://127.0.0.1:3000/test/students */
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


module.exports = {
	programSubmission: programSubmission, 
	programProposal: programProposal,
  	getStudent: getStudent,
  	getAllStudents: getAllStudents,
  	createStudent: createStudent,
  	updateStudent: updateStudent,
  	deleteStudent: deleteStudent
};
