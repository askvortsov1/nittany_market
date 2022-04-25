open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let logged_in u =
  let title_router = function
    | path -> (
      match%sub Value.map ~f:(fun p -> p |> String.split ~on:'/' |> List.filter ~f:(fun str -> String.(str <> ""))) path with
        | [] -> Bonsai.const @@ Vdom.Node.text "Nittany Market"
        | [ "account" ] -> Bonsai.const @@ Vdom.Node.text "My Account"
        | [ "browse" ] | [ "browse"; _ ] ->
            Bonsai.const @@ Vdom.Node.text "Browse Products"
        | [ "products" ] | [ "products"; _ ] ->
            Bonsai.const @@ Vdom.Node.text "Product Details"
        | [ "add_listing" ] -> Bonsai.const @@ Vdom.Node.text "New Listing"
        | _ -> Bonsai.const @@ Vdom.Node.text "Not found")
  in
  let title = Route.router title_router in
  let body_router = function
    | path -> (
        match%sub Value.map ~f:(fun p -> p |> String.split ~on:'/' |> List.filter ~f:(fun str -> String.(str <> ""))) path with
        | [] -> Bonsai.const @@ Vdom.Node.text "Welcome to Nittany Market!"
        | [ "account" ] -> Account.component u
        | [ "browse" ] | [ "browse"; _ ] -> Browse.component
        | [ "products" ] | [ "products"; _ ] -> View_product.component
        | [ "add_listing" ] -> Mutate_product.component u
        | _ -> Bonsai.const @@ Vdom.Node.text "Not found")
  in
  let body = Route.router body_router in
  let%map.Computation title = title and body = body and nav = Nav.component u in
  Templates.skeleton title body ~nav

let login_gate =
  let module P = G.Queries.PayloadQuery in
  let module Loader = Graphql_loader.ForQuery (P) in
  Loader.component
    (fun data ->
      let current_user =
        Value.map data ~f:(fun data -> data.payload.current_user)
      in
      match%sub current_user with
      | Some u -> logged_in u
      | None -> Login.component)
    (Value.return @@ G.Queries.PayloadQuery.makeVariables ())

let component = login_gate

let (_ : _ Start.Handle.t) =
  Start.start Start.Result_spec.just_the_view ~bind_to_element_with_id:"app"
    component
