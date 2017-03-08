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

module.exports = db;
