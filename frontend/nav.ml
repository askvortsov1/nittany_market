open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let component (u : G.Queries.PayloadQuery.t_payload_current_user Value.t) =
  let%sub home_link =
    Route.path_link
      ~children:(Bonsai.const @@ Vdom.Node.text "Home")
      ~attrs:[ Vdom.Attr.class_ "navbar-brand" ]
      "/"
  in
  let%sub account_link =
    Route.path_link ~attrs:[ Vdom.Attr.class_ "nav-link" ] "/account"
  in
  let%arr u = u and home_link = home_link and account_link = account_link in
  let wrap_link link =
    Vdom.Node.li ~attr:(Vdom.Attr.classes ["nav-item"]) [link]
  in
  Vdom.Node.div
    ~attr:
      (Vdom.Attr.classes
         [ "navbar"; "navbar-expand-lg"; "navbar-dark"; "bg-dark" ])
    [
      home_link;
      Vdom.Node.div ~attr:(Vdom.Attr.classes ["collapse"; "navbar-collapse"]) [
        Vdom.Node.ul ~attr:(Vdom.Attr.classes ["navbar-nav"; "mr-auto"]) [
          wrap_link account_link;
        ]
      ];
      Vdom.Node.span
        ~attr:(Vdom.Attr.class_ "navbar-text")
        [ Vdom.Node.textf "Welcome, %s" u.email ];
    ]
