module Rating: sig
    type t = {
        buyer_email : string;
        seller_email : string;
        date : string;
        rating : int;
        rating_desc : string;
      }
    type fields = (string * string * string * int) * string

    include Model_intf.Model with type t := t and type fields := fields
end

module RatingRepository: sig
    include Model_intf.ModelRepository with type t := Rating.t
end