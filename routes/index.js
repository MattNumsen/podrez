var express = require('express');
var router = express.Router();

var db = require("../queries.js");

/* GET home page. 
router.get('/', function(req, res, next) {
  res.render('landingPage', { title: 'Express' });
});
*/
/*GET create account. */
/*
router.get('/createaccount', function (req, res, next) {
	res.render('createAccount', {title: 'Success'});
});
router.get('/profile/:id', function (req, res, next) {
	res.render('studentProfile', {title: 'Success'});
});

router.get('/createProgram', function (req, res, send) {
	res.render('createProgram', {title: 'Create Program'})
});
*/
router.get('/test', db.programProposal);
	


/*
router.get('/test/students', db.getAllStudents);
router.get('/test/students/:id', db.getStudent);
router.post('/test/students', db.createStudent);
router.put('/test/students/:id', db.updateStudent);
router.delete('/test/students/:id', db.deleteStudent);
*/

module.exports = router;
