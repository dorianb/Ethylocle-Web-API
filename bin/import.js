require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var fs = require('fs');
var importStream = require('../lib/import');
var db = require('../lib/db');

if(argv['help'])
{
  console.log('import [--help] [--format {name}] [--type {name}] input\nIntroduction message\n--help          Print this message\n--format {name} One of csv(default) or json\n--type {name}    Type of data to import {user, stop}\ninput           Imported file');
}
else if(argv['format'])
{
  var path = __dirname + "/../db/" + argv['type']
  if((argv['format'] == 'csv') || (argv['format'] == 'json'))
  {
    if(argv['_'][0] != null)
    {
      var client = db(path);
      fs
      .createReadStream(argv['_'][0])
      .on('end', function(){
        console.log('Import finished');
      })
      .pipe(importStream(client, argv['format'], argv['type'], {objectMode: true}));
    }
  }
  else
  {
    console.log('This format is not supported');
  }
}
else
{
  var path = __dirname + "/../db/" + argv['type']
  if(argv['_'][0] != null)
  {
    var client = db(path);
    fs
    .createReadStream(argv['_'][0])
    .on('end', function(){
      console.log('Import finished');
    })
    .pipe(importStream(client, 'csv', argv['type'], {objectMode: true}));
  }
}
