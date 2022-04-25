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

let alert_effect =
  let module AddListing =
    Nittany_market_frontend_graphql.Queries.AddListingMutation
  in
  let module Client =
    Nittany_market_frontend_graphql.Client.ForQuery (AddListing) in
  let alert (s : T.t) =
    let query =
      Client.query
        (AddListing.makeVariables ~category_name:s.category ~title:s.title
           ~product_name:s.product_name
           ~product_description:s.product_description ~price:s.price
           ~quantity:s.quantity ~expires_at:(to_epoch s.expires_at) ())
    in
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
        | Client.Success plid ->
            ignore
              (Js_of_ocaml.Dom_html.window##.location##replace
                 (Js_of_ocaml.Js.string (Util.product_path plid.add_listing)))
        | _ -> alert_err ())
      query
  in
  Effect_lwt.of_deferred_fun alert

let component (u : G.Queries.UserFields.t Value.t) =
  let%sub form = form in
  let%arr form = form and u = u in
  match u.seller_profile with
  | None -> Vdom.Node.text "Only sellers can create product listings."
  | Some _ ->
      let on_submit = Form.Submit.create ~f:alert_effect () in
      let form_vdom = Form.view_as_vdom form ~on_submit in
      Vdom.Node.div ~attr:(Vdom.Attr.classes [ "py-2"; "px-3" ]) [ form_vdom ]
