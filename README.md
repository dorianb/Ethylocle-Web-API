# Node.js project using express Framework

This is the GROUP3 project (Dorian BAGUR, Najlaa SEDKI and Maoqiao ZHOU).
We used coffeeScript as programmation language and MarkDown to document our code.

## Functionalities
* provide a login formular accepting: username and email
* provide a sign up formular requiring: username, email, password, re-password, firstname, lastname
* validation server and client
* import in csv and json
* Export has not been implemented yet

There is only one url for all screens.

## Layout

/.git /.gitignore /bin/start /bin/import /bin/export /lib/app.coffee.md /lib/db.coffee.md, /lib/import.coffee.md, /lib/export.coffee.md /package.json (name, version, dependencies, ...) /public /LICENSE /README.md /tests/db.coffee /tests/app.coffee /tests/import.coffee /views /routes

## LevelDB schema
User namespace key: "users:#{username}:#{property}:" properties: "lastname", "firstname", "email" and "password"

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
