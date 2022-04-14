module Seller = struct

  type t = { email : string; routing_number : string; account_number: int; balance: int }
  [@@deriving fields, csv]
  type key = string

  type fields = string * string * int * int
  let table_name = "seller"
  let key_field = "email"
  let caqti_key_type = Caqti_type.string
  let caqti_types = Caqti_type.(tup4 string string int int)
  let caqtup_of_t u = (u.email, u.routing_number, u.account_number, u.balance)
  let t_of_caqtup (email, routing_number, account_number, balance) = { email; routing_number; account_number; balance }
end

module SellerRepository = Model_intf.Make_SingleKeyModelRepository(Seller)