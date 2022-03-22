module User: sig
    type t = { email : string; password : string }
    type key = string
    type fields = string * string

    include Model_intf.Model with type t := t and type key := key and type fields := fields
end

module UserRepository: sig
    include Model_intf.ModelRepository with type t := User.t and type key = User.key
end