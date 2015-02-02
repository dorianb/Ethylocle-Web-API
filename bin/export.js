require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var fs = require('fs');
var exportStream = require('../lib/export');
var db = require('../lib/db');

if(argv['help'])
{
  console.log('export [--help] [--format {name}] output\nIntroduction message\n--help          Print this message\n--format {name} One of csv(default) or json\noutput          Exported file');
}
else if(argv['format'])
{
  if((argv['format'] == 'csv') || (argv['format'] == 'json'))
  {
    if(argv['_'][0] != null)
    {
      exportStream(__dirname + "/../db/user", argv['format'], {objectMode: true})
      .on('end', function(){
        console.log('Export finished');
      })
      .pipe(fs.createWriteStream(argv['_'][0]));
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
    exportStream(__dirname + "/../db/user", 'csv', {objectMode: true})
    .on('end', function(){
      console.log('Export finished');
    })
    .pipe(fs.createWriteStream(argv['_'][0]));
  }
}
