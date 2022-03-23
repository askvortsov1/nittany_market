module Order: sig
    type t = {
        transaction_id : int;
        seller_email : string;
        listing_id : int;
        buyer_email : string;
        date : string;
        quantity : int;
        payment : int;
      }
    type key = string
    type fields = (int * string * int * string) * (string * int * int)

    include Model_intf.Model with type t := t and type key := key and type fields := fields
end

module OrderRepository: sig
    include Model_intf.ModelRepository with type t := Order.t and type key = Order.key
end