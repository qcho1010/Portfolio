var mysql = require("mysql");

exports.signUpNewProvider = function (data, next) {
    var connection = mysql.createConnection({
        host: "Globalhack.il1.rdbs.ctl.io",
        port: "49424",
        user: "GHack",
        password: "GlobalHack123!",
        database: "globalhack"
    });

    var result;

    connection.connect();

    var name = connection.escape(data.name);
    var phnum = connection.escape(data.phnumber);
    var email = connection.escape(data.email);
    var info = connection.escape(data.info);

    var values = [name, phnum, email, info];


    // connection.query(`INSERT into RequestsToProvide SET (Name, Phnum, Email, AdditionalInfo) VALUES (` + name + `, ` + phnum + `, ` + email + `, ` + info +`);`,  function (err, rows) {
    connection.query(`INSERT into RequestsToProvide (Name, Phnum, Email, AdditionalInfo) VALUES (` + values +`)`,  function (err, rows) {
        console.log(err);
        if (err) next(400);
        else {
            result = 200;
            console.log("Affected rows:" + JSON.stringify(rows));
            connection.end();
            next(result);
        }
    });
};