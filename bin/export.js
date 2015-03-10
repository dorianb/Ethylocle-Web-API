require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var model = require('../lib/factory/model');

if(argv['help'])
{
  console.log('export [--help] [--format {name}] [--type {name}] output\nIntroduction message\n--help          Print this message\n--format {name} One of csv(default) or json\noutput          Output file path');
}
else if(!argv['_'][0])
{
  console.log('Input argument is missing');
}
else if(!argv['type'])
{
  console.log('Type argument is missing');
}
else if(argv['format'])
{
  model().export(argv['format'], argv['type'], argv['_'][0], function(err, message){
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
  model().export('csv', argv['type'], argv['_'][0], function(err, message){
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
