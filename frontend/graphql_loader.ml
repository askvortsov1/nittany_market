open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let private_component :
    type a b view.
    (module Bonsai.Model with type t = a) ->
    a Effect.t Value.t ->
    view_while_loading:view Value.t ->
    (a Value.t -> view Computation.t) ->
    (module Bonsai.Model with type t = b) ->
    b Value.t ->
    view Computation.t =
 fun (module Model) effect ~view_while_loading computation
     (module ReloadTrigger) reload_trigger ->
  let%sub response, set_response = Bonsai.state_opt [%here] (module Model) in
  let%sub on_activate =
    let%arr effect = effect and set_response = set_response in
    let%bind.Effect response_from_server = effect in
    set_response (Some response_from_server)
  in
  let on_change =
    Value.map2 on_activate set_response ~f:(fun e set_resp _ ->
        Effect.ignore_m @@ Effect.all [ set_resp None; e ])
  in
  let%sub () =
    Bonsai.Edge.on_change [%here]
      (module ReloadTrigger)
      reload_trigger ~callback:on_change
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in
  match%sub response with
  | None -> return view_while_loading
  | Some response -> computation response

module ForQuery (Q : G.Queries.Query) = struct
  module QSexpable = G.Queries.SerializableQuery (Q)
  module Client = G.Client.ForQuery (Q)

  module ClientResponse = struct
    type t = Client.response [@@deriving sexp]

    let equal a b = Sexplib0.Sexp.equal (sexp_of_t a) (sexp_of_t b)
  end

  let view_while_loading = Value.return @@ Vdom.Node.text "Loading..."

  let error_handler component =
    Client.(
      function
      | response -> (
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
              Vdom.Node.text err))

  let component ?(trigger = Value.return "") inner qvars =
    let inner_handled = error_handler inner in
    let%sub inner =
      private_component
        (module ClientResponse)
        (Value.map
           ~f:(fun qvars -> Effect_lwt.of_deferred_fun Client.query qvars)
           qvars)
        ~view_while_loading inner_handled
        (module String)
        trigger
    in
    let%arr inner = inner and trigger = trigger in
    ignore trigger;
    inner
end
