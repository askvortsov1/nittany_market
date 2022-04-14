module Category: sig
    type t = { parent_category : string; category_name : string }
    type key = string
    type fields = string * string

    include Model_intf.SingleKeyModel with type t := t and type key := key and type fields := fields
end

module CategoryRepository: sig
    include Model_intf.SingleKeyModelRepository with type t := Category.t and type key = Category.key
end