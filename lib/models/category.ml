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
  let t_of_caqtup (category_name, parent_category) = { category_name; parent_category }
end

module CategoryRepository = Model_intf.Make_ModelRepository(Category)