open Caqti_request.Infix

module Category = struct
  type t = { parent_category : string; category_name : string }
  [@@deriving fields, csv]

  type key = string
  type fields = string * string

  let table_name = "category"
  let key_field = "category_name"
  let caqti_key_type = Caqti_type.string
  let caqti_types = Caqti_type.(tup2 string string)
  let caqtup_of_t u = (u.category_name, u.parent_category)

  let t_of_caqtup (category_name, parent_category) =
    { category_name; parent_category }
end

module CategoryRepository = struct
  include Model_intf.Make_SingleKeyModelRepository (Category)

  let query_parent_category name =
    let query =
      (Caqti_type.string -->* Category.caqti_types)
      @:- Printf.sprintf "SELECT * FROM %s WHERE %s=?" Category.table_name
            "parent_category"
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let%lwt unit_or_error = Db.collect_list query name in
      let raw = Caqti_lwt.or_fail unit_or_error in
      Lwt.map (List.map Category.t_of_caqtup) raw
end