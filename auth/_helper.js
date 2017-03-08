const bcrypt = require('bcrypt');
var SALT_WORK_FACTOR = 10;
var db = require("../initDB.js");

function comparePass(userPassword, databasePassword) {
  return bcrypt.compareSync(userPassword, databasePassword);
}
function createUser (req) {
  const salt = bcrypt.genSaltSync();
  const hash = bcrypt.hashSync(req.body.password, salt);
}

module.exports= {
	comparePass
};