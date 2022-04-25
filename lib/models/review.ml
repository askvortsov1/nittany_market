open Caqti_request.Infix

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

module ReviewRepository = struct
  include Model_intf.Make_ModelRepository (Review)

  let query_listing_id listing_id =
    let query =
      (Caqti_type.int -->* Review.caqti_types)
      @:- Printf.sprintf "SELECT * FROM %s WHERE %s=?" Review.table_name
            "listing_id"
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let%lwt unit_or_error = Db.collect_list query listing_id in
      let raw = Caqti_lwt.or_fail unit_or_error in
      Lwt.map (List.map Review.t_of_caqtup) raw
end