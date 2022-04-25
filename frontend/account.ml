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

let display_change_password change_password =
  Templates.card
    (Vdom.Node.text "Change Password")
    (Vdom.Node.div [ change_password ])

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

let display_seller_profile (prof : G.Queries.UserFields.t_seller_profile) =
  Templates.card
    (Vdom.Node.text "Seller Profile")
    (Vdom.Node.div
       [
         bullet "Current Balance (USD)" (Int.to_string prof.balance);
         bullet "Account Number" (Int.to_string prof.account_number);
         bullet "Routing Number" prof.routing_number;
       ])

let display_vendor_profile (prof : G.Queries.UserFields.t_vendor_profile) =
  Templates.card
    (Vdom.Node.text "Vendor Profile")
    (Vdom.Node.div
       [
         bullet "Business Name" prof.business_name;
         bullet "Customer Service Number" prof.customer_service_number;
         display_address "Business Address" prof.business_address;
       ])

let display_credit_card (card : G.Queries.CreditCardFields.t) =
  let fmt =
    Printf.sprintf "%s Card ending in %s, expires %s" card.card_type
      card.last_four_digits card.expires
  in
  Vdom.Node.li [ Vdom.Node.text fmt ]

let display_credit_cards (cards : G.Queries.CreditCardFields.t array) =
  if Int.equal (Array.length cards) 0 then Vdom.Node.none
  else
    Templates.card
      (Vdom.Node.text "Credit Cards")
      (Vdom.Node.ul (Array.map ~f:display_credit_card cards |> Array.to_list))

let component (u : G.Queries.UserFields.t Value.t) =
  let%sub change_password = Change_password.component in
  let%arr u = u and change_password = change_password in
  Vdom.Node.div
    [
      display_account_info u;
      display_change_password change_password;
      display_opt display_buyer_profile u.buyer_profile;
      display_opt display_seller_profile u.seller_profile;
      display_opt display_vendor_profile u.vendor_profile;
      display_credit_cards u.credit_cards;
    ]
