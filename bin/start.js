require('coffee-script/register')

var forever = require('forever');
var app = require('../lib/app');

app.set('port', process.env.PORT || 3000);

var server = app.listen(app.get('port'), function() {
  console.log('Express server listening on port ' + server.address().port);
});

forever.startServer(server);
