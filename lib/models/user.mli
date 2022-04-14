module User: sig
    type t = { email : string; password : string }
    type key = string
    type fields = string * string

    include Model_intf.SingleKeyModel with type t := t and type key := key and type fields := fields
end

module UserRepository: sig
    include Model_intf.SingleKeyModelRepository with type t := User.t and type key = User.key
end