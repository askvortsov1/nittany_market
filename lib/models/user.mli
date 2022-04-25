module User: sig
    type t = { email : string; password : string }
    type key = string
    type fields = string * string

    include Model_intf.SingleKeyModel with type t := t and type key := key and type fields := fields

    val check_password : t -> string -> bool
end

module UserRepository: sig
    include Model_intf.SingleKeyModelRepository with type t := User.t and type key = User.key

    val update : key -> User.t -> (module Caqti_lwt.CONNECTION) -> unit Lwt.t  
end