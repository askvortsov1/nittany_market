module LoadCsv (M : Models.Model_intf.Model) = struct
  let load ?(transform = fun x -> x) file_name
      (module Db : Caqti_lwt.CONNECTION) =
    let module CsvUtil = Csvfields.Csv.Record (M) in
    let data = CsvUtil.csv_load file_name in
    Lwt_list.iter_s
      (fun raw_entry ->
        let entry = transform raw_entry in
        M.add entry (module Db))
      data
end

module UserCsv = LoadCsv (Models.User)

let load_funcs =
  [
    UserCsv.load
      ~transform:(fun u ->
        { email = u.email; password = Hasher.hash u.password })
      "data/Users.csv";
  ]

let run_load (module Db : Caqti_lwt.CONNECTION) =
  Lwt_list.iter_s
    (fun (load_func : (module Caqti_lwt.CONNECTION) -> unit Lwt.t) ->
      load_func (module Db))
    load_funcs
