module Address: sig
    type t = { address_id: string; zipcode: string; street_num: int; street_name: string }
    type key = string
    type fields = string * string * int * string

    include Model_intf.SingleKeyModel with type t := t and type key := key and type fields := fields
end

module AddressRepository: sig
    include Model_intf.SingleKeyModelRepository with type t := Address.t and type key = Address.key
end