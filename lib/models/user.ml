open Caqti_request.Infix

module User = struct
  type t = { email : string; password : string } [@@deriving fields, csv]
  type key = string
  type fields = string * string

  let table_name = "user"
  let key_field = "email"
  let caqti_key_type = Caqti_type.string
  let caqti_types = Caqti_type.(tup2 string string)
  let caqtup_of_t u = (u.email, u.password)
  let t_of_caqtup (email, password) = { email; password }
  let check_password u p = Auth.Hasher.verify u.password p
end

module UserRepository = struct
  include Model_intf.Make_SingleKeyModelRepository (User)

  let update key (u : User.t) (module Db : Caqti_lwt.CONNECTION) =
    let query =
      Caqti_type.(tup2 string string -->. Caqti_type.unit)
      @:- Printf.sprintf "UPDATE %s SET password=? WHERE email=?"
            User.table_name
    in
    let%lwt unit_or_error = Db.exec query (u.password, key) in
    Caqti_lwt.or_fail unit_or_error
end
