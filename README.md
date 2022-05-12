# CMPSC431W Nittany Market

## Tech Stack

This project is implemented in OCaml, using SQLite3 for the DMBS. Broadly speaking, the tech stack is:

- Bonsai Single Page Application
- GraphQL query server
- Bonsai web server
- SQLite3 Database

The following relevant libraries were used:

In the backend:

- `cmdliner`, for the command line interface
- `dream`, for the backend web server
- `caqti`, for SQL bindings
- `csvfields`, for CSV parsing and import
- `jingoo`, for the templating system
- `argon2`, for bindings to the argon2 hashing algorithm
- `graphql`, for backend GraphQL server support

In the frontend:

- `js_of_ocaml`, to compile OCaml to JS
- `cohttp-client-jsoo`, for the HTTP client that powers the custom GraphQL client
- `graphql_ppx`, for generating type-safe modules for the GraphQL queries/mutations used by this project
- `bonsai`, for the frontend SPA framework
- Assorted Jane Street ppxs, used to derive type conversion functions

## CLI Usage

The website is managed via a command line interface (aliased in the `nmcli` executable), which contains the following commands:

`run`: builds the backend executable and frontend dist JS bundle, then starts the web server on port 8080
`migrate:up`: applies migrations. At this point, this runs all migrations, and is responsible for creating table schemas
`migrate:down`: removes migrations. At this point, this runs all migrations, and is responsible for dropping tables.
`init_data`: Loads in initial data to the database from CSV files provided by CMPSC431W teaching staff.

## Directory Structure and Control Flow

Code that wraps program logic into these commands, as well as initialization code for connecting to the database, may be found in `cli/nmcli.ml`.

The `assets` directory contains static assets served as part of the website; for now, this is just the SPA's generated dist code.

The `data` directory contains CSV files used for testing data.

The `lib` directory contains the backend source code for NittanyMarket. In particular:

- `router.ml` contains routing logic for the backend.
- `migrations.ml` contains code for migrations, as well as the content of the migrations.
- `csv.ml` contains code for loading the provided test data csvs into the database.
- The `auth` directory contains utils for authentication. At the moment, this consists of functions to hash/verify passwords.
- The `csv` directory contains some util types, in order to allow loading nullable fields from the CSV files.
- The `graphql` directory contains the full GraphQL schema implementation, as well as implementation of mutations and some exceptions. This is of particular importance, as it's the API consumed by the frontend SPA.
- The `models` directory contains model specifications for all relations, as well as functor code for generating accessor logic.
- The `views` directory contains handler code for various routes.

The `frontend` directory contains the frontend source code for NittanyMarket. In particular:

- `main.ml` is the entrypoint for the frontend. It defines a login gate, routing non-logged-in users to `login.ml`, as well as a path-based router to the rest of the site for logged-in users.
- `templates.ml` contains several reusable virtual dom elements, such as the page skeleton and a Bootstrap card.
- `nav.ml` contains the navbar, shown to logged-in users.
- `route.mli`/`route.ml` contains a "global" URL `Bonsai.Var.t`, as well as link/route components based around this atom, and route accessors. These are used for intra-site navigation
- `graphql_loader.ml`/`graphql_loader.mli` contain a utility wrapper component that executes a GraphQL query and passes the results to an inner component. It will show a loading indicator during load time, and if there's an error during query evaluation, it will show an appropriate error message.
- `change_password.ml` contains a simple password changing form, used in the `account.ml` page.
- The following files contain pages:
  - `login.ml` contains a login page, which will be shown if users aren't logged in. This, coupled with the logout button on the navbar, fulfills task 1.
  - `account.ml` contains a "account info" page, and includes the password change form. This fulfills task 2.
  - `browse.ml` contains the "browse products" page. These pages have breadcrumbs at the top, any subcategories of the current category, and all products directly in the current category.
  - `view_product.ml` contains a "product details" page. Together with `browse.ml`, this fulfills task 3.
  - `my_listings.ml` contains all product listings sold by the current user. It's not visible to users without a seller profile.
  - `mutate_product.ml` powers both the "create listing" and "edit listing" forms. It's also not visible to users without a seller profile. Together with `my_listings.ml`, this fulfills task 4.
- `util.ml` contains a variety of utils, mostly dealing with page-related URLs.
- `effect_lwt.ml` defines an `Effect_lwt.of_deferred_func` helper, which is the analogue of `Bonsai_web.Effect.of_deferred_func`, byt for Lwt instead of Async.
- The `graphql` folder contains a GraphQL client implemented using `cohttp-lwt-jsoo`, as well as type definitions for all queries generated by `graphql_ppx`.

The `templates` directory contains jingoo templates used to generate HTML returned by the backend.

The `test` directory could contain automated unit tests in the future. Due to time constraints, this was not implemented.

## Design Motivations and Future Potential

Aside from fulfilling the objectives of CMPSC431W, my main objective with this project is to explore OCaml's applicability to web development; in particular, I'm interested in how hard it would be to retain the simplicity and tercity of popular web languages such as Python/PHP while gaining OCaml's type safety and performance guaruntees. To this end, some of the code I am writing is more general than necessary for the CMPSC431W project, since that allows me to experiment with OCaml's generality.

A few particularly interesting pieces:

- The URL var / link / router collection in `route.mli` could be a first step towards a `bonsai_router` library. Necessary improvements would be:
  - Functorizing it, parametrized by some type-safe definition of routes. This could generate tools for generating URLs, parsing URLs, and the router logic itself. Perhaps the [OCaml Routes](https://github.com/anuragsoni/routes) library, or some route-related PPX, could be used to generate a shared set of user-accessible routes between the frontend and backend.
  - Figure out how to highlight links automatically when on the current page.
  - Allow generating an effect to set the URL without using a link component.
- The GraphQL query loader, coupled with the client and the serialization functors defined in `graphql`, could be a companion runtime library to `graphql_ppx`. It would be nice to include deriving ppxs into modules generated by `graphql_ppx` itself; for example, deriving s-expressions to/from the `graphql_ppx` modules.
- A pop-up alert system would be good to have. Since these would be part of global state, I'd probably need to stick alert config into a `Bonsai.Var.t`.
- Some broadly applicable DB interaction functions (insert, get, etc) have been implemented for all applicable models via functors defined in `lib/models/model_intf.ml`. This is nice to have, and was mostly done for practice with functors, but as far as ORMs go it's extremely primitive, and a lot of verbose boilerplate is needed to support Caqti. In the future, I'd like to investigate [ppx_rapper](https://github.com/roddyyaga/ppx_rapper) as an option for terser, type-safe DB code.

Some reflections on OCaml and the libraries I used:

- The language server was struggling with heavy PPX use. I found myself very frequently running VSCode's "Restart Language Server" command, or pressing ctrl+S on already saved files to trigger a re-processing. Without this, I'd get `let%...` usage highlighted in red with "unrecognized syntax extension: ...", and intermediate "_weakxxx" types for local variables and function definitions.
- For some reason, `graphql_ppx` failed to generate a fragment for the recursively-defined `category` object. I haven't confirmed whether this is necessarily caused by recursive GraphQL schemas though.
- The lack of a `bind` operator for Bonsai computations made many otherwise-simple components very challenging, although I understand [why this is neccessary](https://github.com/janestreet/bonsai/blob/master/docs/blogs/why_no_bind.md).
- A **lot** of time was spent trying to figure out which combinators and functions would allow me to do what I want to do within the constraints of the type system. It gets a lot easier with practice, but some of the things that tripped me up were:
  - Getting used to passing in `'a Value.t` instead of `'a` to components. Incremental computation wouldn't really be possible without this, but it's not a way of thinking I was used to.
  - Monadic `let%` syntax. It's definitely a lot simpler and cleaner than using `map`/`sub`/`arr` directly, but I also struggled a bit to track which types some variables actually had.
- Unsurprisingly, most runtime errors came from the "edges" of OCaml: bindings to the browser, parsing/serializing of GraphQL requests to the server, and database calls. The OOP interfaces provided by `Js_of_ocaml` especially were confusing to use.
- I look forward to seeing the `Bonsai` ecosystem grow: I think a major missing component is routing and more publically-available libraries with documentation. That being said, the core philosophy is simple, composable, safe, and extremely powerful.
- Some `Bonsai` tools (`Var`, `Dynamic_scope`) were hard to understand with limited examples, and others (e.g. `Edge`, `state`) I wasn't aware of. I think Bonsai learnability would benefit greatly from expanded, updated public documentation.
- `Js_of_ocaml` output bundles are absolutely huge (>30MB for this project!). It makes sense, but I wonder if there's any way to further bind higher-level libraries to JS, or otherwise optimize down the bundle size.
