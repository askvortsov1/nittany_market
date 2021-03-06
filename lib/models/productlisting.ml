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
    expires_at : Csv.Csv_util.OptInt.t;
  }
  [@@deriving fields, csv]

  type key = int

  type fields =
    (int * string * string * string)
    * (string * string * string * int)
    * int option

  let table_name = "productlisting"
  let key_field = "listing_id"
  let caqti_key_type = Caqti_type.int

  let caqti_types =
    Caqti_type.(
      tup3
        (tup4 int string string string)
        (tup4 string string string int)
        (option int))

  let caqtup_of_t pl =
    ( (pl.listing_id, pl.seller_email, pl.category, pl.title),
      (pl.product_name, pl.product_description, pl.price, pl.quantity),
      pl.expires_at )

  let t_of_caqtup
      ( (listing_id, seller_email, category, title),
        (product_name, product_description, price, quantity),
        expires_at ) =
    {
      listing_id;
      seller_email;
      category;
      title;
      product_name;
      product_description;
      price;
      quantity;
      expires_at;
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

  let update key (p : ProductListing.t) (module Db : Caqti_lwt.CONNECTION) =
    let query =
      Caqti_type.(
        tup2
          (tup2
             (tup4 string string string string)
             (tup3 string int (option int)))
          int
        -->. Caqti_type.unit)
      @:- Printf.sprintf
            "UPDATE %s SET category=?, title=?, product_name=?, \
             product_description=?, price=?, quantity=?, expires_at=? WHERE \
             listing_id=?"
            ProductListing.table_name
    in
    let%lwt unit_or_error =
      Db.exec query
        ( ( (p.category, p.title, p.product_name, p.product_description),
            (p.price, p.quantity, p.expires_at) ),
          key )
    in
    Caqti_lwt.or_fail unit_or_error
end
