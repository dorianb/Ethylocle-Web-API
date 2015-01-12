require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var fs = require('fs');
var importStream = require('../lib/import');
var db = require('../lib/db');

if(argv['help'])
{
  console.log('import [--help] [--format {name}] input\nIntroduction message\n--help          Print this message\n--format {name} One of csv(default) or json\ninput           Imported file');
}
else if(argv['format'])
{
  if((argv['format'] == 'csv') || (argv['format'] == 'json'))
  {
    if(argv['_'][0] != null)
    {
      var client = db("#{__dirname}/../db");
      fs
      .createReadStream(argv['_'][0])
      .on('end', function(){
        console.log('Importation terminée');
      })
      .pipe(importStream(client, {format: argv['format']}, {objectMode: true}));
    }
  }
  else
  {
    console.log('This format is not supported');
  }
}
else
{
  if(argv['_'][0] != null)
  {
    var client = db("#{__dirname}/../db");
    fs
    .createReadStream(argv['_'][0])
    .on('end', function(){
      console.log('Importation terminée');
    })
    .pipe(importStream(client, {format: 'csv'}, {objectMode: true}));
  }
}
