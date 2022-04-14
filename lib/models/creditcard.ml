module CreditCard = struct
  type t = {
    credit_card_num : string;
    card_code : int;
    expire_month : int;
    expire_year : int;
    card_type : string;
    owner_email : string;
  }
  [@@deriving fields, csv]

  type key = string
  type fields = (string * int * int * int) * (string * string)

  let table_name = "creditcard"
  let key_field = "credit_card_num"
  let caqti_key_type = Caqti_type.string

  let caqti_types =
    Caqti_type.(
      tup2 (tup4 string int int int) (tup2 string string))

  let caqtup_of_t c = ((c.credit_card_num, c.card_code, c.expire_month, c.expire_year), (c.card_type, c.owner_email))

  let t_of_caqtup ((credit_card_num, card_code, expire_month, expire_year), (card_type, owner_email)) = {credit_card_num; card_code; expire_month; expire_year; card_type; owner_email}
end

module CreditCardRepository = Model_intf.Make_SingleKeyModelRepository (CreditCard)
