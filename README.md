# CMPSC431W Nittany Market

## Tech Stack

This project is implemented in OCaml, using SQLite3 for the DMBS. The following relevant libraries were used:

- `cmdliner`, for the command line interface
- `dream`, for the backend web server
- `caqti`, for SQL bindings
- `csvfields`, for CSV parsing and import
- `jingoo`, for the templating system
- `argon2`, for bindings to the argon2 hashing algorithm

## CLI Usage

The website is managed via a command line interface (aliased in the `nmcli` executable), which contains the following commands:

`run`: starts the web server on port 8080
`migrate:up`: applies migrations. At this point, this runs all migrations, and is responsible for creating table schemas
`migrate:down`: removes migrations. At this point, this runs all migrations, and is responsible for dropping tables.
`init_data`: Loads in initial data to the database from CSV files provided by CMPSC431W teaching staff.

## Directory Structure and Control Flow

Code that wraps program logic into these commands, as well as initialization code for connecting to the database, may be found in `bin/nmcli.ml`.

The `data` directory contains CSV files used for testing data.

The `lib` directory contains the bulk of the source code for NittanyMarket. In particular:

- `router.ml` contains routing logic for the backend.
- `migrations.ml` contains code for migrations, as well as the content of the migrations.
- `csv.ml` contains code for loading the provided test data csvs into the database.
- The `auth` directory contains utils for authentication. At the moment, this consists of functions to hash/verify passwords.
- The `csv` directory contains some util types, in order to allow loading nullable fields from the CSV files.
- The `models` directory contains model specifications for all relations, as well as functor code for generating accessor logic.
- The `views` directory contains handler code for various routes.

The `templates` directory contains jingoo templates used to generate HTML returned by the backend.

The `test` directory will contain automated unit tests in the future.

## Design Motivations

Aside from fulfilling the objectives of CMPSC431W, my main objective with this project is to explore OCaml's applicability to web development; in particular, I'm interested in how hard it would be to retain the simplicity and tercity of popular web languages such as Python/PHP while gaining OCaml's type safety and performance guaruntees. To this end, some of the code I am writing is more general than necessary for the CMPSC431W project, since that allows me to experiment with OCaml's generality.

## Model System

Some broadly applicable DB interaction functions (insert, get, etc) have been implemented for all applicable models via functors defined in `lib/models/model_intf.ml`. Other functions will be defined as needed in individual models.
