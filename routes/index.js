var express = require('express');
var router = express.Router();

var db = require('../queries');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('landingPage', { title: 'Express' });
});

/*GET create account. */

router.get('/createaccount', function (req, res, next) {
	res.render('createAccount', {title: 'Success'});
});

router.get('/test/students', db.getAllStudents);

module.exports = router;
