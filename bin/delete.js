require('coffee-script/register')

var argv = require('minimist')(process.argv.slice(2));
var fs = require('fs');
var db = require('../lib/db');

if(argv['help'])
{
  console.log('delete [--help] [--type {name}] id\nIntroduction message\n--help          Print this message\n--type {name}   Type of data to delete {user, trip}\nid              Identification number of entry in database');
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
        if(err)
        {
          console.log(err.message);
        }
        else if(user.id)
        {
          client.users.del(user.id, user, function(err) {
            if(err)
            {
              console.log(err.message);
            }
            else
            {
              client.users.delByEmail(user.email, user, function(err) {
                if(err)
                {
                  console.log(err.message);
                }
                else
                {
                  client.close(function(err) {
                    if(err)
                    {
                      console.log(err.message);
                    }
                    else
                    {
                      console.log('User ' + user.id + ' deleted');
                    }
                  });
                }
              });
            }
          });
        }
        else
        {
          console.log("User does not exist");
        }
      });
    }
    else
    {
      console.log('Input argument is missing');
    }
  }
  else if(argv['type'] == 'trip')
  {
    if(argv['_'][0] != null)
    {
      var client = db(path);
      client.trips.get(argv['_'][0], function(err, trip) {
        delPassengerIndex = function(i, callback) {
          if(i <= trip.numberOfPassenger)
          {
            client.trips.delByPassenger(trip["passenger_" + i], trip, function(err) {
              if(err)
              {
                callback(err);
              }
              else
              {
                delPassengerIndex(i+1, callback);
              }
            });
          }
          else
          {
            callback(null);
          }
        }
        if(trip.id != null)
        {
          delPassengerIndex(1, function(err) {
            client.trips.del(trip.id, trip, function(err) {
              if(err)
              {
                console.log(err.message);
              }
              else
              {
                client.close(function(err) {
                  if(err)
                  {
                    console.log(err.message);
                  }
                  else
                  {
                    console.log('Trip ' + trip.id + ' deleted');
                  }
                });
              }
            });
          });
        }
        else
        {
          console.log('Trip does not exist');
        }
      });
    }
    else
    {
      console.log('Input argument is missing');
    }
  }
  else
  {
    console.log('This type of data is not supported');
  }
}
else
{
  console.log('Type argument is missing');
}
