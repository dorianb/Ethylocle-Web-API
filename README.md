# Ethylocle Web API

[![Build Status](https://travis-ci.org/dorianb/Ethylocle-Web-API.svg?branch=master)](https://travis-ci.org/dorianb/Ethylocle-Web-API)

This web api displays two services for mobile application clients. It aims to help people sharing a taxi ride.

## Functionalities
* Manage account profile: sign in, sign up, update, delete, etc.
* Manage ride: create ride, get rides, join ride, get ride data, etc.
* Manage database: show, import, export, etc.

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

### Show data
```
node ./bin/show user
node ./bin/show ride
```
Just pipe it with grep command to look at a particular entry !
```
node ./bin/show user | grep id:8
```

### Import data
```
node ./bin/import --format csv --type users "user sample.csv"
node ./bin/import --format json --type users "user sample.json"
node ./bin/import --format csv --type stops "ratp_stops_with_routes.csv"
```

### Export data
```
node ./bin/export --format csv users.csv
node ./bin/export --format csv stops.csv
```

## Services documentation

### User services

#### Sign in
If the email and password are correct, a session cookie is returned to the client
```
url: domain/usr/signin
Paramètres: {"email", "password"}
Retour: { "result": bool, "data": null }
```

#### Check password
Allows client to check password before allowing client user to reset critical information
```
url: domain/usr/checkpassword
Paramètres: {"password"}
Retour: { "result": bool, "data": null }
```

#### Sign up
Client user can sign up with an email and password if the email is not already used
```
url: domain/usr/signup
Paramètres: {"email", "password"}
Retour: { "result": bool, "data": null }
```

#### Sign out
Just destroying the cookie session
```
url: domain/usr/signout
Paramètres: {}
Retour: { "result": bool, "data": null }
```

#### Update email
As the email is set as index in user database, it needs special treatments
```
url: domain/usr/updateemail
Paramètres: {"email"}
Retour: { "result": bool, "data": null }
```

#### Update user data
This request allows client to update user data as password but not email and id
```
url: domain/usr/update
Paramètres: {"image", "lastName", "firstName", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "password", "latitude", "longitude", "lastKnownPositionDate", "bac", "lastBacKnownDate" }
Retour: { "result": bool, "data": null}
```

#### Get user
Client will get user data without password
```
url: domain/usr/get
Paramètres: {}
Retour: { "result": bool, "data": userObject }
```

#### Get user by Id
A user can get data of another user by providing user's id
```
url: domain/usr/getbyid
Paramètres: { "id" }
Retour: { "result": bool, "data": ["id", "image", "lastName", "firstName", "birthDate", "gender", "phone"] }
```

#### Delete user
Delete all user data in user database if he hasn't got a ride in progress
```
url: domain/usr/delete
Paramètres: {}
Retour: { "result": bool, "data": null }
```

### Ride services

#### Has ride
Allows client to know if the user has a ride in progress
```
url: domain/rd/has
Paramètres: {}
Retour: { "result": bool, "data": null }
```

#### Search rides
Client can search rides available based on user's preference
```
url: domain/rd/search
Paramètres: { "latStart", "lonStart", "latEnd", "lonEnd", "dateTime", "numberOfPeople" }
Retour: { "result": bool, "data": [ { "id", "distanceToStart", "distanceToEnd", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPassenger", "maxPrice" }, ... ] }
```

#### Join ride
User can join an existing ride by providing its id and the numberOfPeople. If the ride is no longer available, the user will be notified in this way.
```
url: domain/rd/join
Paramètres: { "id", "numberOfPeople" }
Retour: { "result": bool, "data": null }
```

#### Create ride
If the user doesn't want to join an existing ride, he can create his own one by providing the essential data requested
```
url: domain/rd/create
Paramètres: { "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "numberOfPeople" }
Retour: { "result": bool, "data": null }
```

#### Get ride
Once a user has joined or created a ride, he can access all the ride data such as passengers id
```
url: domain/rd/get
Paramètres: {}
Retour: { "result": bool, "data": { "id", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "maxPrice", "numberOfPassenger", "passenger_1", "passenger_2", "passenger_3", "passenger_4" } }
```

#### Get ride by id
All users can access a part of the ride data by providing ride id
```
url: domain/rd/getbyid
Paramètres: { "id" }
Retour: { "result": bool, "data": { "id", "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "maxPrice", "numberOfPassenger" } }
```

### LevelDB schema
```
User namespace key: "users:#{id}:#{property}"
Properties: "email", "image", "lastName", "firstName", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "password", "latitude", "longitude", "lastKnownPositionDate", "bac" and "lastBacKnownDate"
birthDate format: 'DD-MM-YYYY'
User namespace index: "usersEmailIndex:#{email}:#{property}"
property: "id"

Ride namespace key: "rides:#{id}:#{property}"
Properties: "addressStart", "latStart", "lonStart", "addressEnd", "latEnd", "lonEnd", "dateTime", "price", "numberOfPassenger", "passenger_1", "passenger_2", "passenger_3" and "passenger_4"
dateTime format: 'DD-MM-YYYY H:mm'
Ride namespace index: "ridesPassengerIndex:#{userId}:#{id}:#{property}"
property: "dateTime"

Ridesearch namespace key: "ridesearch:#{userId}:#{distance}:#{rideId}"

Stop namespace key: "stops:#{id}:#{property}"
Properties: "name", "desc", "lat", "lon", "lineType" and "lineName"
Stop namespace index: "stops:#{lineType}:#{id}"
```
