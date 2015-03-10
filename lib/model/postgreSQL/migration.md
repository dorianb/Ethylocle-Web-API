# How to migrate to postgreSQL

The factory pattern used for this project allows anybody to migrate to other SGBD than LevelDB (PostgreSQL for instance).
To do so,
* You first need to implement the abstract class defined upside.
* Then, add a case in the factory for instanciating the new database model.
* Finally, modify the variable "factory" defined in package.json to fit with the desired case value.
