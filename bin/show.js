require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var model = require('../lib/factory/model');

if(argv['help'])
{
  console.log('show [--help] name\nIntroduction message\n--help          Print this message\nname            Type of data to show {user, ride, ridesearch, stop}');
}
else if(argv['_'][0])
{
  model().show(argv['_'][0], function(err, message) {
    if(err)
    {
      console.log(err.message);
    }
    else
    {
      console.log(message);
    }
  });
}
else
{
  console.log('Input argument is missing');
}
