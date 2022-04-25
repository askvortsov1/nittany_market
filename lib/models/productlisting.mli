module ProductListing: sig
    type t = {
        seller_email : string;
        listing_id : int;
        category : string;
        title : string;
        product_name : string;
        product_description : string;
        price: string;
        quantity: int;
      }
    type key = int
    type fields = (int * string * string * string) * (string * string * string * int)

    include Model_intf.SingleKeyModel with type t := t and type key := key and type fields := fields
end

module ProductListingRepository: sig
    include Model_intf.SingleKeyModelRepository with type t := ProductListing.t and type key = ProductListing.key

    val query_category: string -> (module Caqti_lwt.CONNECTION) -> ProductListing.t list Lwt.t
end