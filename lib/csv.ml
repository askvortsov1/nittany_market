module LoadCsv (M : Models.Model_intf.Model) = struct
  let load ?transform file_name (module Db : Caqti_lwt.CONNECTION) =
    let module CsvUtil = Csvfields.Csv.Record (M) in
    let data = CsvUtil.csv_load file_name in
    Lwt_list.iter_s
      (fun raw_entry ->
        let entry =
          match transform with Some f -> f raw_entry | None -> raw_entry
        in
        M.add entry (module Db))
      data
end

module UserCsv = LoadCsv (Models.User)

let load_funcs = [ UserCsv.load ?transform:None "data/Users.csv" ]

let run_load (module Db : Caqti_lwt.CONNECTION) =
  let load_funcs = [ UserCsv.load "data/Users.csv" ] in
  Lwt_list.iter_s
    (fun (load_func : (module Caqti_lwt.CONNECTION) -> unit Lwt.t) ->
      load_func (module Db))
    load_funcs
