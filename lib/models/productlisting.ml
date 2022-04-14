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

  type key = string

  type fields =
    (int * string * string * string) * (string * string * string * int)

  let table_name = "productlisting"
  let key_field = "listing_id"
  let caqti_key_type = Caqti_type.string

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
      listing_id;seller_email;category;title;product_name;product_description;price;quantity
    }
end

module ProductListingRepository =
  Model_intf.Make_SingleKeyModelRepository (ProductListing)
