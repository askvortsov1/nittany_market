open! Core
open! Bonsai_web
module Form = Bonsai_web_ui_form
module E = Form.Elements

module T = struct
  type t = { email : string; password : string }
  [@@deriving sexp_of, typed_fields]

  let form_for_field : type a. a Typed_field.t -> a Form.t Computation.t =
    function
    | Email ->
        E.Textbox.string
          ~extra_attrs:(Value.return [ Vdom.Attr.class_ "form-control" ])
          [%here]
    | Password ->
        E.Textbox.string [%here]
          ~extra_attrs:
            (Value.return
               [ Vdom.Attr.type_ "password"; Vdom.Attr.class_ "form-control" ])
end

let form = Form.Typed.Record.make (module T)

let alert_effect =
  let module Login = Nittany_market_frontend_graphql.Queries.LoginMutation in
  let module Client = Nittany_market_frontend_graphql.Client.ForQuery (Login) in
  let alert (s : T.t) =
    let query =
      Client.query (Login.makeVariables ~email:s.email ~password:s.password ())
    in
    Lwt.map
      (fun (_resp, (body : Login.t option)) ->
        let success = match body with Some a -> a.login | None -> false in
        if success then ignore Js_of_ocaml.Dom_html.window##.location##reload
        else
          ignore
            (Js_of_ocaml.Dom_html.window##alert
               (Js_of_ocaml.Js.string "Login failed")))
      query
  in
  Effect_lwt.of_deferred_fun alert

let component =
  let%map.Computation form = form in
  let on_submit = Form.Submit.create ~f:alert_effect () in
  let form_vdom = Form.view_as_vdom form ~on_submit in
  let body = Vdom.Node.div ~attr:(Vdom.Attr.classes ["py-2"; "px-3"]) [form_vdom] in
  let title = Vdom.Node.text "Log In" in
  Templates.skeleton title body