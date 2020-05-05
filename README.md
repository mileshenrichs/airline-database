# Airline Database

This is a Python command-line tool that connects to our MySQL airline database and calls its stored procedures.

## Setup
__Begin by cloning this repository:__
```
$ git clone https://github.com/mileshenrichs/airline-database.git
$ cd airline-database
```

To connect to the SQL database, the application depends on two environment variables being set on your computer:
1. __AIRLINE_DB_NAME__: The name of the MySQL database where your tables are.  You can find this in the "Schemas" tab on the left side of your MySQL Workbench.
1. __AIRLINE_DB_PASSWORD__: The password you use to connect to MySQL.

[This page](https://www.hows.tech/2019/03/how-to-set-environment-variables-in-windows-10.html) describes how to set environment variables in Windows.

__Next, install the MySQL connector from the project's `requirements.txt` file:__
```
$ pip install -r requirements.txt
```

__Finally, you can run the demo of the application:__
```
$ python demo.py
```