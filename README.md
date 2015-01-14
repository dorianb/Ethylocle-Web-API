# Ethyloclé backend web server using Express framework for Node.js

I used CoffeeScript as programmation language and MarkDown to document our code.

## Functionalities
* Manage account profile: sign in, sign up, update and delete
* Get taxi, metro and bus at proximity
* Import in csv and json
* Export has not been implemented yet

### Sign in request
url: 195.154.9.74:3000/Connexion
Paramètres: {email, password}
Retour: {result: bool, data: string}

### Sign up request
url: 195.154.9.74:3000/Inscription
Paramètres: {email, password}
Retour: {result: bool, data: string}

### Sign out request
url: 195.154.9.74:3000/Deconnexion
Paramètres: { }
Retour: {result: bool, data: null}

### Get user information request
url: 195.154.74:3000/Utilisateur
Paramètres: {}
Retour: {result: bool, data: userObject}

## LevelDB schema
User namespace key: "users:#{email}:#{property}:" properties: "email", "picture", "lastname", "firstname", "age", "gender", "weight", "address", "zipCode", "city", "country", "phone", "vehicul" et "password"

## Install
Use this command to install locally all the dependencies needed:
```
npm install
```

## Test
Several tests are provided, execute them using the following command:
```
npm test
```
You can test the sign in request from a client using the following command on windows:
```
curl -H "Content-Type: application/json" -X POST http://195.154.9.74:3000/connexion -d "{\"email\":\"dorian@ethylocle.com\", \"password\": \"1234\"}"
```
You can test the sign up request from a client using the following command on windows:
```
curl -H "Content-Type: application/json" -X POST http://195.154.9.74:3000/inscription -d "{\"email\":\"dorian@ethylocle.com\", \"password\": \"1234\"}"
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
node ./bin/import --format csv sample.csv
node ./bin/import --format json sample.json
```
