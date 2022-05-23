open Bonsai_web

(* TODO: at some point in the future, this should be functorized, with variant types for the routes. *)

val curr_path_novalue : unit -> string
val curr_path : string Value.t

val set_path : string -> unit Ui_effect.t

(* Links and Components *)
(* TODO: support both internal and external links. *)

val link_vdom :
  ?attrs:Vdom.Attr.t list ->
  ?children:Vdom.Node.t ->
  string ->
  Vdom.Node.t

val link :
  ?attrs:Vdom.Attr.t list ->
  ?children:Vdom.Node.t Computation.t ->
  string Value.t ->
  Vdom.Node.t Computation.t

val router :
  (string Value.t -> Vdom.Node.t Computation.t) -> Vdom.Node.t Computation.t
