module Review = struct
  type t = {
    buyer_email : string;
    seller_email : string;
    listing_id : int;
    review_desc : string;
  }
  [@@deriving fields, csv]

  type fields = string * string * int * string

  let table_name = "review"
  let caqti_types = Caqti_type.(tup4 string string int string)

  let caqtup_of_t r =
    (r.buyer_email, r.seller_email, r.listing_id, r.review_desc)

  let t_of_caqtup (buyer_email, seller_email, listing_id, review_desc) =
    { buyer_email; seller_email; listing_id; review_desc }
end

module ReviewRepository = Model_intf.Make_ModelRepository (Review)
