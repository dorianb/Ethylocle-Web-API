require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var show = require('../lib/show');
var db = require('../lib/db');

if(argv['help'])
{
  console.log('show [--help] name\nIntroduction message\n--help          Print this message\nname            Type of data to show {user, trip, tripsearch, stop}');
}
else if(argv['_'][0])
{
  var path = __dirname + "/../db/" + argv['_'][0]
  show(path, argv['_'][0], function(err, nbRows) {
    if(err)
    {
      console.log("Error at row " + nbRows + ": " + err.message);
    }
    else
    {
      console.log(argv['_'][0] + ": " + nbRows);
    }
  });
}
else
{
  console.log('Input argument is missing');
}
