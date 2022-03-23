module Review: sig
    type t = {
        buyer_email : string;
        seller_email : string;
        listing_id : int;
        review_desc : string;
      }
    type key = string
    type fields = string * string * int * string

    include Model_intf.Model with type t := t and type key := key and type fields := fields
end

module ReviewRepository: sig
    include Model_intf.ModelRepository with type t := Review.t and type key = Review.key
end