open Caqti_request.Infix

module ProductListing = struct
  type t = {
    seller_email : string;
    listing_id : int;
    category : string;
    title : string;
    product_name : string;
    product_description : string;
    price : string;
    quantity : int;
  }
  [@@deriving fields, csv]

  type key = int

  type fields =
    (int * string * string * string) * (string * string * string * int)

  let table_name = "productlisting"
  let key_field = "listing_id"
  let caqti_key_type = Caqti_type.int

  let caqti_types =
    Caqti_type.(
      tup2 (tup4 int string string string) (tup4 string string string int))

  let caqtup_of_t pl =
    ( (pl.listing_id, pl.seller_email, pl.category, pl.title),
      (pl.product_name, pl.product_description, pl.price, pl.quantity) )

  let t_of_caqtup
      ( (listing_id, seller_email, category, title),
        (product_name, product_description, price, quantity) ) =
    {
      listing_id;
      seller_email;
      category;
      title;
      product_name;
      product_description;
      price;
      quantity;
    }
end

module ProductListingRepository = struct
  include Model_intf.Make_SingleKeyModelRepository (ProductListing)

  let query_category category =
    let query =
      (Caqti_type.(tup2 string string) -->* ProductListing.caqti_types)
      @:- Printf.sprintf
            "SELECT * FROM %s WHERE LOWER(%s)=LOWER(?) OR LOWER(%s)=LOWER(?) \
             COLLATE NOCASE"
            ProductListing.table_name "category" "category"
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let category_and =
        Re.replace_string (Re.str " and " |> Re.compile) ~by:" ? " category
      in
      let category_ampersand =
        Re.replace_string (Re.str " ? " |> Re.compile) ~by:" and " category
      in
      let%lwt unit_or_error =
        Db.collect_list query (category_and, category_ampersand)
      in
      let raw = Caqti_lwt.or_fail unit_or_error in
      Lwt.map (List.map ProductListing.t_of_caqtup) raw

  let query_seller_email seller_email =
    let query =
      (Caqti_type.string -->* ProductListing.caqti_types)
      @:- Printf.sprintf "SELECT * FROM %s WHERE %s=?" ProductListing.table_name
            "seller_email"
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let%lwt unit_or_error = Db.collect_list query seller_email in
      let raw = Caqti_lwt.or_fail unit_or_error in
      Lwt.map (List.map ProductListing.t_of_caqtup) raw

  let get_max_id () =
    let query =
      (Caqti_type.unit -->! Caqti_type.int)
      @:- Printf.sprintf "SELECT MAX(listing_id) FROM %s"
            ProductListing.table_name
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let%lwt unit_or_error = Db.find query () in
      Caqti_lwt.or_fail unit_or_error
end