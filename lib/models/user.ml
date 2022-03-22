module type DB = Caqti_lwt.CONNECTION

module R = Caqti_request
module T = Caqti_type

type t = { email : string; password : string } [@@deriving yojson, fields, csv]

let add =
  let query =
    R.exec (T.tup2 T.string T.string) "INSERT INTO user VALUES (?, ?)"
  in
  fun u (module Db : DB) ->
    let%lwt unit_or_error = Db.exec query (u.email, u.password) in
    Caqti_lwt.or_fail unit_or_error
