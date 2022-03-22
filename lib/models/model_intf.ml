module type Model = sig
  type t
  type key
  type fields

  val table_name : string
  val key_field : string
  val caqti_key_type : key Caqti_type.t
  val caqti_types : fields Caqti_type.t
  val caqtup_of_t : t -> fields
  val t_of_caqtup : fields -> t

  include Csvfields.Csv.Csvable with type t := t
end

module type ModelRepository = sig
  type t
  type key

  val add : t -> (module Caqti_lwt.CONNECTION) -> unit Lwt.t
  val get : key -> (module Caqti_lwt.CONNECTION) -> t option Lwt.t
end

module Make_ModelRepository (M : Model) = struct
  type t = M.t
  type key = M.key

  let prepared_pattern =
    let len = List.length M.csv_header in
    List.init len (fun _ -> "?") |> String.concat ","

  let add x (module Db : Caqti_lwt.CONNECTION) =
    let query =
      Caqti_request.exec M.caqti_types
        (Printf.sprintf "INSERT INTO %s VALUES (%s)" M.table_name prepared_pattern)
    in
    let%lwt unit_or_error = Db.exec query (M.caqtup_of_t x) in
    Caqti_lwt.or_fail unit_or_error

  let get email =
    let query =
      Caqti_request.find_opt M.caqti_key_type M.caqti_types
        (Printf.sprintf "SELECT * FROM %s WHERE %s=?" M.table_name M.key_field)
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let%lwt unit_or_error = Db.find_opt query email in
      let raw = Caqti_lwt.or_fail unit_or_error in
      Lwt.map (Option.map M.t_of_caqtup) raw
end