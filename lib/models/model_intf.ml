module type Model = sig
  type key
  type t
  include Csvfields.Csv.Csvable_simple with type t := t

  val add: t -> (module Caqti_lwt.CONNECTION) -> unit Lwt.t
  val get: key -> (module Caqti_lwt.CONNECTION) -> t option Lwt.t
end