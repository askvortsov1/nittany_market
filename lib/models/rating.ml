module Rating = struct
  type t = {
    buyer_email : string;
    seller_email : string;
    date : string;
    rating : int;
    rating_desc : string;
  }
  [@@deriving fields, csv]

  type fields = (string * string * string * int) * string

  let table_name = "rating"
  let caqti_types = Caqti_type.(tup2 (tup4 string string string int) string)

  let caqtup_of_t r =
    ((r.buyer_email, r.seller_email, r.date, r.rating), r.rating_desc)

  let t_of_caqtup ((buyer_email, seller_email, date, rating), rating_desc) =
    { buyer_email; seller_email; date; rating; rating_desc }
end

module RatingRepository = Model_intf.Make_ModelRepository (Rating)
