require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var model = require('../lib/factory/model');

if(argv['help'])
{
  console.log('import [--help] [--format {name}] [--type {name}] input\nIntroduction message\n--help          Print this message\n--format {name} One of csv or json\n--type {name}   Type of data to import {user, stop}\ninput           Input file path');
}
else if(!argv['_'][0])
{
  console.log('Input argument is missing');
}
else if(!argv['type'])
{
  console.log('Type argument is missing');
}
else if(!argv['format'])
{
  console.log('Format argument is missing');
}
else
{
  model().import(argv['format'], argv['type'], argv['_'][0], function(err, message)
  {
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
