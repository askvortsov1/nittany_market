(lang dune 3.0)

(name nittany_market)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Author Name")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name nittany_market)
 (allow_empty)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends 
   ocaml 
   dune
   lwt
   dream
   cmdliner
   caqti-driver-sqlite3
   argon2
   csvfields
   ppx_csv_conv
   re
   bonsai
   graphql_ppx
   ppx_yojson_conv_lib
   jingoo
   ppx_yojson_conv
   cohttp-lwt-jsoo 
 )
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
