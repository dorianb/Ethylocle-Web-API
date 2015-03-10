require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var model = require('../lib/factory/model');

if(argv['help'])
{
  console.log('export [--help] [--format {name}] output\nIntroduction message\n--help          Print this message\n--format {name} One of csv(default) or json\noutput          Exported file');
}
else if(!argv['_'][0])
{
  console.log('Input argument is missing');
}
else if(argv['format'])
{
  model().export(argv['format'], argv['_'][0], function(err, message){
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
  model().export('csv', argv['_'][0], function(err, message){
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
