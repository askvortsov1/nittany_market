module Address = struct

  type t = { address_id: string; zipcode: string; street_num: int; street_name: string }
  [@@deriving yojson, fields, csv]
  type key = string

  type fields = string * string * int * string
  let table_name = "address"
  let key_field = "address_id"
  let caqti_key_type = Caqti_type.string
  let caqti_types = Caqti_type.(tup4 string string int string)
  let caqtup_of_t a = (a.address_id, a.zipcode, a.street_num, a.street_name)
  let t_of_caqtup (address_id, zipcode, street_num, street_name) = { address_id; zipcode; street_num; street_name }
end

module AddressRepository = Model_intf.Make_ModelRepository(Address)