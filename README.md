# Ethyloclé backend web server using Express framework

I used CoffeeScript as programmation language and MarkDown to document our code.

## Functionalities
* Manage account profile: sign in, sign up, update and delete
* Manage trip: create trip, get trips, join trip, get trip data
* Import users data from csv and json files
* Export users data to csv file

## User request

### Sign in
```
url: 195.154.9.74:3000/usr/signin
Paramètres: {email, password}
Retour: { "result": bool, "data": null }
```

### Check password
```
url: 195.154.9.74:3000/usr/checkpassword
Paramètres: {password}
Retour: { "result": bool, "data": null }
```

### Sign up
```
url: 195.154.9.74:3000/usr/signup
Paramètres: {email, password}
Retour: { "result": bool, "data": null }
```

### Sign out
```
url: 195.154.9.74:3000/usr/signout
Paramètres: {}
Retour: { "result": bool, "data": null }
```

### Update email
```
url: 195.154.9.74:3000/usr/updateemail
Paramètres: {email}
Retour: { "result": bool, "data": null }
```

### Update user data
```
url: 195.154.9.74:3000/usr/update
Paramètres: {"image", "lastname", "firstname", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "vehicul", "password", "latitude", "longitude", "lastKnownPositionDate", "bac", "lastBacKnownDate" }
Retour: { "result": bool, "data": null}
```

### Get user data
```
url: 195.154.74:3000/usr/get
Paramètres: {}
Retour: { "result": bool, "data": userObject }
```

### Delete user
```
url: 195.154.9.74:3000/usr/delete
Paramètres: {}
Retour: { "result": bool, "data": null }
```

## Trip request

### Has trip
```
url: 195.154.9.74:3000/trp/hastrip
Paramètres: {}
Retour: { "result": bool, "data": "id" }
```

### Get trips
```
url: 195.154.9.74:3000/trp/gettrips
Paramètres: { "latStart", "lonStart", "latEnd", "lonEnd", "dateTime", "numberOfPeople" }
Retour: { "result": bool, "data": [ { "id", "distanceToStart", "distanceToEnd", "dateTime", "numberOfPassenger", "maxPrice" }, ... ] }
```

### Join trip
```
url: 195.154.9.74:3000/trp/jointrip
Paramètres: { "id", "numberOfPeople" }
Retour: { "result": bool, "data": null }
```

### Create trip
```
url: 195.154.9.74:3000/trp/createtrip
Paramètres: { "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPeople" }
Retour: { "result": bool, "data": "id" }
```

### Get trip data
```
url: 195.154.9.74:3000/trp/gettripdata
Paramètres: {}
Retour: { "result": bool, "data": { "id", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "price", "numberOfPassenger" } }
```

## LevelDB schema
```
User namespace key: "users:#{id}:#{property}"
Properties: "email", "image", "lastname", "firstname", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "password", "latitude", "longitude", "lastKnownPositionDate", "bac" and "lastBacKnownDate"
birthDate format: 'dd-MM-yyyy'
User namespace index: "users:#{email}:#{property}"
properties: "id"

Trip namespace key: "trips:#{id}:#{property}"
Properties: "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "price", "numberOfPassenger", "passenger_1", "passenger_2", "passenger_3" and "passenger_4"
dateTime format: 'dd-MM-yyyy hh:mm'
Trip namespace index: "tripsPassengerIndex:#{userId}:#{trip.id}:#{property}"
properties: "dateTime"

Tripsearch namespace key: "tripsearch:#{userId}:#{distance}:#{tripId}"

Stop namespace key: "stops:#{id}:#{property}"
Properties: "name", "desc", "lat", "lon", "lineType" and "lineName"
Stop namespace index: "stops:#{lineType}:#{id}"
```

## Install
Use this command to install locally all the dependencies needed:
```
npm install
```
Use this command to install globally forever module:
```
npm install forever -g
```

## Test
Several tests are provided, execute them using the following command:
```
npm test
```
You can test the sign in request from a client using the following command on windows:
```
curl -H "Content-Type: application/json" -X POST http://195.154.9.74:3000/usr/signin -d "{\"email\":\"dorian@ethylocle.com\", \"password\": \"1234\"}"
```
You can test the sign up request from a client using the following command on windows:
```
curl -H "Content-Type: application/json" -X POST http://195.154.9.74:3000/usr/signup -d "{\"email\":\"dorian@ethylocle.com\", \"password\": \"1234\"}"
```

## Launch server
Execute the following command for launching server:
```
npm start
```
If you want to launch server in production mode, run the following command:
```
forever start ./bin/start.js
```

## Manage database
Several scripts are provided for managing database

### Import data
```
node ./bin/import --format csv --type users "user sample.csv"
node ./bin/import --format json --type users "user sample.json"
node ./bin/import --format csv --type stops "ratp_stops_with_routes.csv"
```

### Export data
```
node ./bin/export --format csv users.csv
```

### Delete data
```
node ./bin/delete --type user 0
```
