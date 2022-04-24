open! Core
open! Bonsai_web
open Bonsai.Let_syntax

module G = Nittany_market_frontend_graphql

let private_component :
    type a view.
    (module Bonsai.Model with type t = a) ->
    a option Effect.t Value.t ->
    view_while_loading:view Value.t ->
    (a Value.t -> view Computation.t) ->
    view Computation.t =
 fun (module Model) effect ~view_while_loading computation ->
  let%sub data, set_data = Bonsai.state_opt [%here] (module Model) in
  let%sub on_activate =
    let%arr effect = effect and set_data = set_data in
    let%bind.Effect data_fetched_from_server = effect in
    set_data data_fetched_from_server
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in
  match%sub data with
  | None -> return view_while_loading
  | Some data -> computation data

module ForQuery (Q : G.Queries.Query) = struct
  module QSexpable = G.Queries.SerializableQuery (Q)
  module Client = G.Client.ForQuery (Q)

  let view_while_loading = Value.return @@ Vdom.Node.text "Loading..."
  let load_data qvars = Lwt.map (fun (_resp, body) -> body) (Client.query qvars)

  let component inner qvars =
    private_component
      (module QSexpable)
      (Value.return ((Effect_lwt.of_deferred_fun load_data) qvars))
      ~view_while_loading inner
end
