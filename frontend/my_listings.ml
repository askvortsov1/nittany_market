open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let display_listings
    (my_listings :
      G.Queries.ProductListingFields.t_product_listing array Value.t) =
  let%arr my_listings = my_listings in
  Vdom.Node.div
    [
      Route.link_vdom "/add_listing"
        ~attrs:[ Vdom.Attr.classes [ "btn"; "btn-primary"; "mt-3" ] ] ~children:(Vdom.Node.text "Add Listing");
      Vdom.Node.hr ();
      (match my_listings with
      | x when Int.equal (Array.length x) 0 ->
          Vdom.Node.text "No Current Listings"
      | my_listings ->
          Vdom.Node.div ~attr:(Vdom.Attr.class_ "row")
            (Array.to_list (Array.map my_listings ~f:Browse.product_card)));
    ]

let component (u : G.Queries.UserFields.t Value.t) =
  let%sub inner =
    let module MyListings = G.Queries.MyListingsQuery in
    let module Loader = Graphql_loader.ForQuery (MyListings) in
    Loader.component
      (fun product_query ->
        let product =
          Value.map ~f:(fun data -> data.my_listings) product_query
        in
        display_listings product)
      (Value.return (MyListings.makeVariables ()))
  in
  let%arr inner = inner and u = u in
  match u.seller_profile with
  | None -> Vdom.Node.text "Only sellers can create product listings."
  | Some _ -> inner
