module type DB = Caqti_lwt.CONNECTION

module R = Caqti_request
module T = Caqti_type

type key = string
type t = { email : string; password : string } [@@deriving yojson, fields, csv]

let add =
  let query =
    R.exec (T.tup2 T.string T.string) "INSERT INTO user VALUES (?, ?)"
  in
  fun u (module Db : DB) ->
    let%lwt unit_or_error = Db.exec query (u.email, u.password) in
    Caqti_lwt.or_fail unit_or_error

let get email =
  let query =
    R.find_opt T.string
      T.(tup2 string string)
      "SELECT * FROM user WHERE email=?"
  in
  fun (module Db : DB) ->
    let%lwt unit_or_error = Db.find_opt query email in
    let raw = Caqti_lwt.or_fail unit_or_error in
    Lwt.map (Option.map (fun (email, password) -> { email; password })) raw