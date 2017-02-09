var promise = require('bluebird');

var options = {
  // Initialization Options
  promiseLib: promise
};

var pgp = require('pg-promise')(options);
var connectionString = 'postgres://localhost:5432/podrez';
var db = pgp(connectionString);

// add query functions

module.exports = {
  getAllStudents: getAllStudents,
  getStudent: getStudent,
  createStudent: createStudent,
  updateStudent: updateStudent,
  removeStudent: removeStudent
};
