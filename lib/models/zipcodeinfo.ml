module ZipcodeInfo = struct
  type t = {
    zipcode : string;
    city : string;
    state_id : string;
    population : Csv.Csv_util.OptInt.t;
    density : Csv.Csv_util.OptFloat.t;
    county_name : string;
    timezone : string;
  }
  [@@deriving fields, csv]

  type key = string
  type fields = (string * string * string * int option) * (float option * string * string)

  let table_name = "zipcode_info"
  let key_field = "zipcode"
  let caqti_key_type = Caqti_type.string

  let caqti_types =
    Caqti_type.(tup2 (tup4 string string string (option int)) (tup3 (option float) string string))

  let caqtup_of_t a =
    ( (a.zipcode, a.city, a.state_id, a.population),
      (a.density, a.county_name, a.timezone) )

  let t_of_caqtup
      ((zipcode, city, state_id, population), (density, county_name, timezone))
      =
    { zipcode; city; state_id; population; density; county_name; timezone }
end

module ZipcodeInfoRepository = Model_intf.Make_ModelRepository (ZipcodeInfo)
