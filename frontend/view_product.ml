open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let display_product
    (product_listing :
      G.Queries.ProductListingFields.t_product_listing option Value.t) =
  let%arr product_listing = product_listing in
  match product_listing with
  | None -> Vdom.Node.text "Product Not Found"
  | Some product_listing ->
      Vdom.Node.div
        [
          Vdom.Node.p
            [
              Vdom.Node.text "Category: ";
              Route.link_path_vdom
                (Util.category_path product_listing.category_name)
                ~children:(Vdom.Node.text product_listing.category_name);
              Vdom.Node.h2 [ Vdom.Node.text product_listing.title ];
              Templates.bullet "Product Name" product_listing.product_name;
              Templates.bullet "Product Description"
                product_listing.product_description;
              Templates.bullet "Price" product_listing.price;
              Templates.bullet "Quantity"
                (Int.to_string product_listing.quantity);
              (match product_listing.seller with
              | Some s -> Templates.bullet "Sold By" s.email
              | None -> Vdom.Node.none);
            ];
        ]

let component =
  let deoptionize x = match x with Some x -> x | None -> "" in
  let get_slug path =
    let re = Js_of_ocaml.Regexp.regexp "^/products/?(.*)/?$" in
    let plid_match = Js_of_ocaml.Regexp.string_match re path 0 in
    plid_match
    |> Option.bind ~f:(fun m -> Js_of_ocaml.Regexp.matched_group m 1)
    |> Option.map ~f:Js_of_ocaml.Url.urldecode
  in

  let module ProductListing = G.Queries.ProductListingQuery in
  let module Loader = Graphql_loader.ForQuery (ProductListing) in
  Loader.component
    (fun product_query ->
      let product =
        Value.map ~f:(fun data -> data.product_listing) product_query
      in
      display_product product)
    (Value.map
       ~f:(fun v ->
         ProductListing.makeVariables
           ~id:(Int.of_string (deoptionize @@ get_slug v))
           ())
       Route.curr_path)
