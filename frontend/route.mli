open Bonsai_web

(* TODO: at some point in the future, this should be functorized, with variant types for the routes. *)

(* A component used to link to internal pages in the SPA.
 *  TODO: support both internal and external links. *)
val link :
  ?attrs:Vdom.Attr.t list ->
  ?children:Vdom.Node.t Computation.t ->
  Uri.t ->
  Vdom.Node.t Computation.t

(* Same as `link`, but takes a string to an internal path. *)
val path_link :
  ?attrs:Vdom.Attr.t list ->
  ?children:Vdom.Node.t Computation.t ->
  string ->
  Vdom.Node.t Computation.t

val router :
  (string Value.t -> Vdom.Node.t Computation.t) -> Vdom.Node.t Computation.t
