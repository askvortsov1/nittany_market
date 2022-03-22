module type Model = sig
  type t
  include Csvfields.Csv.Csvable_simple with type t := t

  val add: t -> (module Caqti_lwt.CONNECTION) -> unit Lwt.t
end