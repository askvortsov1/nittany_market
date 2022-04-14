module Order = struct
  type t = {
    transaction_id : int;
    seller_email : string;
    listing_id : int;
    buyer_email : string;
    date : string;
    quantity : int;
    payment : int;
  }
  [@@deriving fields, csv]

  type key = string
  type fields = (int * string * int * string) * (string * int * int)

  let table_name = "orders"
  let key_field = "transaction_id"
  let caqti_key_type = Caqti_type.string

  let caqti_types =
    Caqti_type.(tup2 (tup4 int string int string) (tup3 string int int))

  let caqtup_of_t o =
    ( (o.transaction_id, o.seller_email, o.listing_id, o.buyer_email),
      (o.date, o.quantity, o.payment) )

  let t_of_caqtup
      ( (transaction_id, seller_email, listing_id, buyer_email),
        (date, quantity, payment) ) =
    {
      transaction_id;
      seller_email;
      listing_id;
      buyer_email;
      date;
      quantity;
      payment;
    }
end

module OrderRepository = Model_intf.Make_SingleKeyModelRepository (Order)
