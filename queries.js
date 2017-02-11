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

module.exports = {
  getAllStudents: getAllStudents
};
