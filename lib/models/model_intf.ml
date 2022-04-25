open Caqti_request.Infix

module type Model = sig
  type t
  type fields

  val table_name : string
  val caqti_types : fields Caqti_type.t
  val caqtup_of_t : t -> fields
  val t_of_caqtup : fields -> t

  include Csvfields.Csv.Csvable with type t := t
end

module type SingleKeyModel = sig
  include Model

  type key

  val key_field : string
  val caqti_key_type : key Caqti_type.t
end

module type ModelRepository = sig
  type t

  val add : t -> (module Caqti_lwt.CONNECTION) -> unit Lwt.t
  val all : unit -> (module Caqti_lwt.CONNECTION) -> t list Lwt.t
end

module type SingleKeyModelRepository = sig
  include ModelRepository

  type key

  val get : key -> (module Caqti_lwt.CONNECTION) -> t option Lwt.t
end

module Make_ModelRepository (M : Model) = struct
  type t = M.t

  let prepared_pattern =
    let len = List.length M.csv_header in
    List.init len (fun _ -> "?") |> String.concat ","

  let add x (module Db : Caqti_lwt.CONNECTION) =
    let query =
      (M.caqti_types -->! Caqti_type.unit)
      @:- Printf.sprintf "INSERT INTO %s VALUES (%s)" M.table_name
            prepared_pattern
    in
    let%lwt unit_or_error = Db.find query (M.caqtup_of_t x) in
    Caqti_lwt.or_fail unit_or_error

  let all () =
    let query =
      (Caqti_type.unit -->* M.caqti_types)
      @:- Printf.sprintf "SELECT * FROM %s" M.table_name
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let%lwt unit_or_error = Db.collect_list query () in
      let raw = Caqti_lwt.or_fail unit_or_error in
      Lwt.map (List.map M.t_of_caqtup) raw
end

module Make_SingleKeyModelRepository (M : SingleKeyModel) = struct
  include Make_ModelRepository (M)

  type key = M.key

  let get id =
    let query =
      (M.caqti_key_type -->? M.caqti_types)
      @:- Printf.sprintf "SELECT * FROM %s WHERE %s=?" M.table_name M.key_field
    in
    fun (module Db : Caqti_lwt.CONNECTION) ->
      let%lwt unit_or_error = Db.find_opt query id in
      let raw = Caqti_lwt.or_fail unit_or_error in
      Lwt.map (Option.map M.t_of_caqtup) raw
end