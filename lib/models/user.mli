type key = string
type t = { email : string; password : string } [@@deriving yojson, fields, csv]

include Model_intf.Model with type t := t and type key := key