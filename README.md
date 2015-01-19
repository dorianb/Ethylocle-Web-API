# Ethyloclé backend web server using Express framework for Node.js

I used CoffeeScript as programmation language and MarkDown to document our code.

## Functionalities
* Manage account profile: sign in, sign up, update and delete
* Get taxi, metro and bus at proximity
* Import in csv and json
* Export has not been implemented yet

### Sign in request
url: 195.154.9.74:3000/usr/signin
Paramètres: {email, password}
Retour: {result: bool, data: string}

### Sign up request
url: 195.154.9.74:3000/usr/signup
Paramètres: {email, password}
Retour: {result: bool, data: string}

### Sign out request
url: 195.154.9.74:3000/usr/signout
Paramètres: { }
Retour: {result: bool, data: null}

### Update user data request
url: 195.154.9.74:3000/usr/update
Paramètres: {"image", "lastname", "firstname", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "vehicul", "password", "latitude", "longitude", "lastKnownPositionDate", "bac", "lastBacKnownDate" }
Retour: {result: bool, data: null}

### Get user data request
url: 195.154.74:3000/usr/get
Paramètres: {}
Retour: {result: bool, data: userObject}

### Delete user request
url: 195.154.74.3000/usr/delete
Paramètres: {}
Retour: {result: bool, data: null}

## LevelDB schema
User namespace key: "users:#{email}:#{property}:"
Properties: "image", "lastname", "firstname", "birthDate", "gender", "weight", "address", "zipCode", "city", "country", "phone", "vehicul", "password", "latitude", "longitude", "lastKnownPositionDate", "bac", "lastBacKnownDate"

Stop namespace key: "stops:#{id}:#{property}:"
Properties: "name", "desc", "lat", "lon", "lineType" and "lineName"
Stop namespace index: "stops:#{lineType}:#{id}"

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

## Import script
A script is provided to import json and csv data in database. Use the following commands to import data:

```
node ./bin/import --format csv --type users "user sample.csv"
node ./bin/import --format json --type users "user sample.json"
node ./bin/import --format csv --type stops "ratp_stops_with_routes.csv"

node ./bin/export --format csv "users.csv"
```
