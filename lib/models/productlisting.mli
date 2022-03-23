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
    type key = string
    type fields = (int * string * string * string) * (string * string * string * int)

    include Model_intf.Model with type t := t and type key := key and type fields := fields
end

module ProductListingRepository: sig
    include Model_intf.ModelRepository with type t := ProductListing.t and type key = ProductListing.key
end