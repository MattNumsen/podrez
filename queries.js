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
		res.status(200)
		.json({
			status: 'success', 
			data: data, 
			message: 'Retreived ONE student'
		});
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
  	getStudent: getStudent,
  	getAllStudents: getAllStudents,
  	createStudent: createStudent,
  	updateStudent: updateStudent,
  	deleteStudent: deleteStudent
};
