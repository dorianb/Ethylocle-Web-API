require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var fs = require('fs');
var db = require('../lib/db');

if(argv['help'])
{
  console.log('delete [--help] [--type {name}] id\nIntroduction message\n--help          Print this message\n--type {name}   Type of data to delete {user}\nid              Identification number of entry in database');
}
else if(argv['type'])
{
  var path = __dirname + "/../db/" + argv['type']
  if(argv['type'] == 'user')
  {
    if(argv['_'][0] != null)
    {
      var client = db(path);
      client.users.get(argv['_'][0], function(err, user) {
        if(err != null)
        {
          console.log(err.message);
        }
        else
        {
          client.users.del(user.id, user, function(err) {
            if(err != null)
            {
              console.log(err.message);
            }
            else
            {
              client.users.delByEmail(user.email, user, function(err) {
                if(err != null)
                {
                  console.log(err.message);
                }
                else
                {
                  console.log('Utilisateur ' + user.id + ' supprimé');
                }
              })
            }
          })
        }
      })
    }
  }
  else
  {
    console.log('This type of data is not supported');
  }
}
else
{
  var path = __dirname + "/../db/user"
  if(argv['_'][0] != null)
  {
    var client = db(path);
    client.users.get(argv['_'][0], function(err, user) {
      if(err != null)
      {
        console.log(err.message);
      }
      else
      {
        client.users.del(user.id, user, function(err) {
          if(err != null)
          {
            console.log(err.message);
          }
          else
          {
            client.users.delByEmail(user.email, user, function(err) {
              if(err != null)
              {
                console.log(err.message);
              }
              else
              {
                console.log('Utilisateur ' + user.id + ' supprimé');
              }
            })
          }
        })
      }
    })
  }
}
