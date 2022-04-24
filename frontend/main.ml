open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let logged_in =
  let title_router = function
    | path -> (
        match%sub path with
        | "/" -> Bonsai.const @@ Vdom.Node.text "Home"
        | "/something" -> Bonsai.const @@ Vdom.Node.text "Home"
        | _ -> Bonsai.const @@ Vdom.Node.text "Not found")
  in
  let title = Route.router title_router in
  let body_router = function
    | path -> (
        match%sub path with
        | "/" -> Route.path_link ~children:(Bonsai.const @@ Vdom.Node.text "Account") "/account"
        | "/account" -> Route.path_link ~children:(Bonsai.const @@ Vdom.Node.text "Home") "/"
        | _ -> Bonsai.const @@ Vdom.Node.text "Not found")
  in
  let body = Route.router body_router in
  let%map.Computation title = title and body = body in
  Templates.skeleton title body

let component =
  let module P = G.Queries.PayloadQuery in
  let module Loader = Graphql_loader.ForQuery(P) in
  Loader.component (fun data ->
      let current_user =
        Value.map data ~f:(fun data -> data.payload.current_user)
      in
      match%sub current_user with
      | Some _u -> logged_in
      | None -> Login.component) (G.Queries.PayloadQuery.makeVariables ())

let (_ : _ Start.Handle.t) =
  Start.start Start.Result_spec.just_the_view ~bind_to_element_with_id:"app"
    component
