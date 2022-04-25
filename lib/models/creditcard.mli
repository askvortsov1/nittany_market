module CreditCard : sig
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

  include
    Model_intf.SingleKeyModel
      with type t := t
       and type key := key
       and type fields := fields
end

module CreditCardRepository : sig
  include
    Model_intf.SingleKeyModelRepository
      with type t := CreditCard.t
       and type key = CreditCard.key

  val query_owner_email :
    string -> (module Caqti_lwt.CONNECTION) -> CreditCard.t list Lwt.t
end