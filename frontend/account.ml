open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let display_opt component v =
  match v with None -> Vdom.Node.none | Some v -> component v

let bullet key value =
  Vdom.Node.li
    [ Vdom.Node.strong [ Vdom.Node.textf "%s: " key ]; Vdom.Node.text value ]

let display_account_info (u : G.Queries.UserFields.t) =
  Templates.card
    (Vdom.Node.text "Account Info")
    (Vdom.Node.div [ bullet "Email" u.email ])

let display_address title (addr : G.Queries.AddressFields.t option) =
  let fmt =
    match addr with
    | None -> ""
    | Some addr ->
        Printf.sprintf "%d %s, %s" addr.street_num addr.street_name addr.zipcode
  in
  bullet title fmt

let display_buyer_profile (prof : G.Queries.UserFields.t_buyer_profile) =
  Templates.card
    (Vdom.Node.text "Buyer Profile")
    (Vdom.Node.div
       [
         bullet "First Name" prof.first_name;
         bullet "Last Name" prof.last_name;
         bullet "Gender" prof.gender;
         bullet "Age" (Int.to_string prof.age);
         display_address "Home Address" prof.home_address;
         display_address "Billing Address" prof.billing_address;
       ])

let component (u : G.Queries.UserFields.t Value.t) =
  let%arr u = u in
  Vdom.Node.div
    [
      display_account_info u; display_opt display_buyer_profile u.buyer_profile;
    ]
