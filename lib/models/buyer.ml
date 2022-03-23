module Buyer = struct
  type t = {
    email : string;
    first_name : string;
    last_name : string;
    gender : string;
    age : int;
    home_address_id : string;
    billing_address_id : string;
  }
  [@@deriving fields, csv]

  type key = string
  type fields = (string * string * string * string) * (int * string * string)

  let table_name = "buyer"
  let key_field = "email"
  let caqti_key_type = Caqti_type.string

  let caqti_types =
    Caqti_type.(
      tup2 (tup4 string string string string) (tup3 int string string))

  let caqtup_of_t b =
    ( (b.email, b.first_name, b.last_name, b.gender),
      (b.age, b.home_address_id, b.billing_address_id) )

  let t_of_caqtup
      ( (email, first_name, last_name, gender),
        (age, home_address_id, billing_address_id) ) =
    {
      email;
      first_name;
      last_name;
      gender;
      age;
      home_address_id;
      billing_address_id;
    }
end

module BuyerRepository = Model_intf.Make_ModelRepository (Buyer)
