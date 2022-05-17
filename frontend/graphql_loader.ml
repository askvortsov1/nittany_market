open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let private_component :
    type data view trigger.
    view_while_loading:view Value.t ->
    computation:(data Value.t -> view Computation.t) ->
    (module Bonsai.Model with type t = data) ->
    data Effect.t Value.t ->
    (module Bonsai.Model with type t = trigger) ->
    trigger Value.t ->
    view Computation.t =
 fun ~view_while_loading ~computation (module Model) effect
     (module ReloadTrigger) reload_trigger ->
  (* The API response state is optional, since it won't be set until loaded. *)
  let%sub response, set_response = Bonsai.state_opt [%here] (module Model) in

  let%sub on_activate =
    let%arr effect = effect and set_response = set_response in
    let%bind.Effect response_from_server = effect in
    set_response (Some response_from_server)
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in

  let on_change =
    Value.map2 on_activate set_response ~f:(fun refetch set_resp _ ->
        Effect.ignore_m (Effect.all [ set_resp None; refetch ]))
  in
  let%sub () =
    Bonsai.Edge.on_change [%here]
      (module ReloadTrigger)
      reload_trigger ~callback:on_change
  in

  (* If the response has been loaded, we display the component.
   * Otherwise, we show a loading indicator.
   *)
  match%sub response with
  | None -> return view_while_loading
  | Some response -> computation response

(* This is the concrete implementation of our query loader. *)
module ForQuery (Q : G.Queries.Query) = struct
  module QSexpable = G.Queries.SerializableQuery (Q)
  module Client = G.Client.ForQuery (Q)

  module ClientResponse = struct
    type t = Client.response [@@deriving sexp]

    let equal a b = Sexplib0.Sexp.equal (sexp_of_t a) (sexp_of_t b)
  end

  let view_while_loading = Value.return @@ Vdom.Node.text "Loading..."

  let error_handler component response =
    Client.(
      match%sub response with
      | Success body -> component body
      | Unauthorized -> Bonsai.const @@ Vdom.Node.text "Error: Unauthorized"
      | Forbidden -> Bonsai.const @@ Vdom.Node.text "Error: Forbidden"
      | NotFound -> Bonsai.const @@ Vdom.Node.text "Error: Not Found"
      | TooManyRequests ->
          Bonsai.const
          @@ Vdom.Node.text "Error: Too Many Requests, try again later."
      | OtherError err ->
          let%arr err = err in
          Vdom.Node.text err)

  let component ?(trigger = Value.return "") inner qvars =
    (* Wraps the component in an error handler, since the
     * type returned by the API client will be `ClientResponse`, not `Q.t` directly.
     *)
    let inner_handled = error_handler inner in
    (* Map our query variables into an effect that fetches the query.
     * `Effect_lwt.of_deffered_fun` turns an async function into an effect function.
     *)
    let fetch_query =
      Value.map
        ~f:(fun qvars -> Effect_lwt.of_deferred_fun Client.query qvars)
        qvars
    in
    private_component ~view_while_loading ~computation:inner_handled
      (module ClientResponse)
      fetch_query
      (module String)
      trigger
end
