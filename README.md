# Ethyloclé backend web server using Express framework for Node.js

I used CoffeeScript as programmation language and MarkDown to document our code.

## Functionalities
* Manage account profile: sign in, sign up, update and delete
* Get taxi, metro and bus at proximity
* Import in csv and json
* Export has not been implemented yet

### Login request
url: 195.154.9.74:3000/Connexion
Paramètres: { email, password }
Retour: {result: bool, message: string}

### SignUp request
url: 195.154.9.74:3000/Inscription
Paramètres: { email, password }
Retour: {result: bool, message: string}

## Layout

/.git /.gitignore /bin/start /bin/import /bin/export /lib/app.coffee.md /lib/db.coffee.md, /lib/import.coffee.md, /lib/export.coffee.md /package.json (name, version, dependencies, ...) /public /LICENSE /README.md /tests/db.coffee /tests/app.coffee /tests/import.coffee /views /routes

## LevelDB schema
User namespace key: "users:#{email}:#{property}:" properties: "email" and "password"

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
You can test a request from a client using the following command on windows:
```
curl -H "Content-Type: application/json" -X POST http://195.154.9.74:3000/connexion -d "{\"email\":\"dorian@ethylocle.com\", \"password\": \"1234\"}"
```

## Launch server
Execute the following command for launching server:
```
npm start
```

## Import script
A script is provided to import json and csv data in database. Use the following commands to import data:

```
node ./bin/import --format csv sample.csv
node ./bin/import --format json sample.json
```
