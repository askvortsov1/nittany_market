module CreditCard: sig
    type t = {
        credit_card_num : string;
        card_code : int;
        expire_month : int;
        expire_year : int;
        card_type : string;
        owner_email : string;
      }
    type key = string
    type fields = (string * int * int * int) * (string * string)

    include Model_intf.Model with type t := t and type key := key and type fields := fields
end

module CreditCardRepository: sig
    include Model_intf.ModelRepository with type t := CreditCard.t and type key = CreditCard.key
end