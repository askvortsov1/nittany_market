module Seller: sig
    type t = { email : string; routing_number : string; account_number: int; balance: int }
    type key = string
    type fields = string * string * int * int

    include Model_intf.Model with type t := t and type key := key and type fields := fields
end

module SellerRepository: sig
    include Model_intf.ModelRepository with type t := Seller.t and type key = Seller.key
end