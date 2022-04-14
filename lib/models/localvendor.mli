module LocalVendor: sig
    type t = { email : string; business_name : string; business_address_id: string; customer_service_number: string }
    type key = string
    type fields = string * string * string * string

    include Model_intf.SingleKeyModel with type t := t and type key := key and type fields := fields
end

module LocalVendorRepository: sig
    include Model_intf.SingleKeyModelRepository with type t := LocalVendor.t and type key = LocalVendor.key
end