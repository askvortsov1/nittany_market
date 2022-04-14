module LocalVendor = struct
  type t = {
    email : string;
    business_name : string;
    business_address_id : string;
    customer_service_number : string;
  }
  [@@deriving fields, csv]

  type key = string
  type fields = string * string * string * string

  let table_name = "localvendor"
  let key_field = "email"
  let caqti_key_type = Caqti_type.string
  let caqti_types = Caqti_type.(tup4 string string string string)

  let caqtup_of_t lv =
    ( lv.email,
      lv.business_name,
      lv.business_address_id,
      lv.customer_service_number )

  let t_of_caqtup
      (email, business_name, business_address_id, customer_service_number) =
    { email; business_name; business_address_id; customer_service_number }
end

module LocalVendorRepository = Model_intf.Make_SingleKeyModelRepository (LocalVendor)
