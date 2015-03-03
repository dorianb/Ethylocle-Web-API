require('coffee-script/register');

var fs = require('fs');
var https = require('https');
var app = require('../lib/host/app');

app.set('port', process.env.PORT || 443);

var hskey = fs.readFileSync(__dirname + "/../resource/key/key.pem");
var hscert = fs.readFileSync(__dirname + "/../resource/key/cert.pem");

var options = {
    key: hskey,
    cert: hscert
};

var server = https.createServer(options, app).listen(app.get('port'), function() {
  console.log('Express server listening on port ' + server.address().port);
});
