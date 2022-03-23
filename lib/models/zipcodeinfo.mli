module ZipcodeInfo : sig
  type t = {
    zipcode : string;
    city : string;
    state_id : string;
    population : int option;
    density : float option;
    county_name : string;
    timezone : string;
  }

  type key = string
  type fields = (string * string * string * int option) * (float option * string * string)

  include
    Model_intf.Model
      with type t := t
       and type key := key
       and type fields := fields
end

module ZipcodeInfoRepository : sig
  include
    Model_intf.ModelRepository
      with type t := ZipcodeInfo.t
       and type key = ZipcodeInfo.key
end