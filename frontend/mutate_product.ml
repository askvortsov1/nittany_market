open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module Form = Bonsai_web_ui_form
module E = Form.Elements
module G = Nittany_market_frontend_graphql

module T = struct
  type t = {
    category : string;
    title : string;
    product_name : string;
    product_description : string;
    price : string;
    quantity : int;
    expires_at : Date.t;
  }
  [@@deriving sexp_of, typed_fields]

  let form_for_field : type a. a Typed_field.t -> a Form.t Computation.t =
    function
    | Category ->
        E.Textbox.string [%here]
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
    | Title ->
        E.Textbox.string [%here]
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
    | Product_name ->
        E.Textbox.string [%here]
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
    | Product_description ->
        E.Textbox.string [%here]
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
    | Price ->
        E.Textbox.string [%here]
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
    | Quantity ->
        E.Number.int [%here]
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
          ~default:0 ~step:1 ()
    | Expires_at ->
        E.Date_time.date [%here]
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
end

let form = Form.Typed.Record.make (module T)
let to_epoch date = Date.diff date Date.unix_epoch * 24 * 60 * 60

let update_query id (s : T.t) =
  let module UpdateListing =
    Nittany_market_frontend_graphql.Queries.UpdateListingMutation
  in
  let module Client =
    Nittany_market_frontend_graphql.Client.ForQuery (UpdateListing) in
  let query =
    Client.query
      (UpdateListing.makeVariables ~id ~category_name:s.category ~title:s.title
         ~product_name:s.product_name ~product_description:s.product_description
         ~price:s.price ~quantity:s.quantity ~expires_at:(to_epoch s.expires_at)
         ())
  in
  Lwt.map
    (fun resp -> match resp with Client.Success _ -> Some id | _ -> None)
    query

let create_query (s : T.t) =
  let module AddListing =
    Nittany_market_frontend_graphql.Queries.AddListingMutation
  in
  let module Client =
    Nittany_market_frontend_graphql.Client.ForQuery (AddListing) in
  let query =
    Client.query
      (AddListing.makeVariables ~category_name:s.category ~title:s.title
         ~product_name:s.product_name ~product_description:s.product_description
         ~price:s.price ~quantity:s.quantity ~expires_at:(to_epoch s.expires_at)
         ())
  in
  Lwt.map
    (fun resp ->
      match resp with Client.Success plid -> Some plid.add_listing | _ -> None)
    query

let alert_effect query_func =
  let alert (s : T.t) =
    let query = query_func s in
    Lwt.map
      (fun resp ->
        let alert_err () =
          ignore
            (Js_of_ocaml.Dom_html.window##alert
               (Js_of_ocaml.Js.string
                  "Add Listing failed. Most likely, either data is missing or \
                   the category you entered does not exist."))
        in
        match resp with
        | Some plid ->
            ignore
              (Js_of_ocaml.Dom_html.window##.location##replace
                 (Js_of_ocaml.Js.string (Util.product_path plid)))
        | _ -> alert_err ())
      query
  in
  Effect_lwt.of_deferred_fun alert

let create (u : G.Queries.UserFields.t Value.t) =
  let%sub form = form in
  let%arr form = form and u = u in
  match u.seller_profile with
  | None -> Vdom.Node.text "Only sellers can create product listings."
  | Some _ ->
      let on_submit = Form.Submit.create ~f:(alert_effect create_query) () in
      let form_vdom = Form.view_as_vdom form ~on_submit in
      Vdom.Node.div ~attr:(Vdom.Attr.classes [ "py-2"; "px-3" ]) [ form_vdom ]

let edit (u : G.Queries.UserFields.t Value.t)
    (l : G.Queries.ProductListingFields.t Value.t) =
  let%sub form = form in
  let init_form =
    Value.map2 form l ~f:(fun form l ->
        Form.set form
          {
            T.category = l.category_name;
            title = l.title;
            product_name = l.product_name;
            product_description = l.product_description;
            price = l.price;
            quantity = l.quantity;
            expires_at = Util.date_of_epoch l.expires_at;
          })
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate:init_form () in
  let%arr form = form and u = u and l = l in
  match u.seller_profile with
  | None -> Vdom.Node.text "Only sellers can create product listings."
  | Some _ ->
      let on_submit =
        Form.Submit.create ~f:(alert_effect (update_query l.id)) ()
      in
      let form_vdom = Form.view_as_vdom form ~on_submit in
      Vdom.Node.div ~attr:(Vdom.Attr.classes [ "py-2"; "px-3" ]) [ form_vdom ]

let get_slug path =
  let re = Js_of_ocaml.Regexp.regexp "^/edit_listing/?(.*)/?$" in
  let cid_match = Js_of_ocaml.Regexp.string_match re path 0 in
  cid_match
  |> Option.bind ~f:(fun m -> Js_of_ocaml.Regexp.matched_group m 1)
  |> Option.map ~f:Js_of_ocaml.Url.urldecode

let edit_loader (u : G.Queries.UserFields.t Value.t) =
  let module ProductListing = G.Queries.ProductListingQuery in
  let module Loader = Graphql_loader.ForQuery (ProductListing) in
  let qvars =
    Value.map
      ~f:(fun v ->
        let slug = View_product.deoptionize @@ get_slug v in
        let id = match slug with "" -> 0 | _ -> Int.of_string slug in
        ProductListing.makeVariables ~id ())
      Route.curr_path
  in
  Loader.component ~trigger:Route.curr_path
    (fun product_query ->
      let product =
        Value.map ~f:(fun data -> data.product_listing) product_query
      in
      match%sub product with Some product -> edit u product | None -> create u)
    qvars

let component (u : G.Queries.UserFields.t Value.t) =
  match%sub Route.curr_path with
  | "/edit_listing" | "/edit_listing/" -> create u
  | _ -> edit_loader u
