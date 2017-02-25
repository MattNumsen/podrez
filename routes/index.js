var express = require('express');
var router = express.Router();

var db = require("../queries.js");

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('landingPage', { title: 'Express' });
});

/*GET create account. */

router.get('/createaccount', function (req, res, next) {
	res.render('createAccount', {title: 'Success'});
});



router.get('/createProgram', db.programProposal);
router.post('/createProgram', db.programSubmission);



	
router.get('/profile/:id', db.getStudent);


/*
router.get('/test/students', db.getAllStudents);
router.get('/test/students/:id', db.getStudent);
router.post('/test/students', db.createStudent);
router.put('/test/students/:id', db.updateStudent);
router.delete('/test/students/:id', db.deleteStudent);
*/

module.exports = router;
