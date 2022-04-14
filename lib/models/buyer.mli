module Buyer: sig
    type t = {
        email : string;
        first_name : string;
        last_name : string;
        gender : string;
        age : int;
        home_address_id : string;
        billing_address_id : string;
      }
    type key = string
    type fields = (string * string * string * string) * (int * string * string)

    include Model_intf.SingleKeyModel with type t := t and type key := key and type fields := fields
end

module BuyerRepository: sig
    include Model_intf.SingleKeyModelRepository with type t := Buyer.t and type key = Buyer.key
end