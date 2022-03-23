module Category: sig
    type t = { parent_category : string; category_name : string }
    type key = string
    type fields = string * string

    include Model_intf.Model with type t := t and type key := key and type fields := fields
end

module CategoryRepository: sig
    include Model_intf.ModelRepository with type t := Category.t and type key = Category.key
end