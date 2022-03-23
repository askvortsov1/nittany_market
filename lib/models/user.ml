module User = struct

  type t = { email : string; password : string }
  [@@deriving fields, csv]
  type key = string

  type fields = string * string
  let table_name = "user"
  let key_field = "email"
  let caqti_key_type = Caqti_type.string
  let caqti_types = Caqti_type.(tup2 string string)
  let caqtup_of_t u = (u.email, u.password)
  let t_of_caqtup (email, password) = { email; password }
end

module UserRepository = Model_intf.Make_ModelRepository(User)