open! Core
open! Bonsai_web
module Form = Bonsai_web_ui_form
module E = Form.Elements

module T = struct
  type t = { current_password : string; new_password : string }
  [@@deriving sexp_of, typed_fields]

  let form_for_field : type a. a Typed_field.t -> a Form.t Computation.t =
    function
    | Current_password ->
        E.Textbox.string [%here]
          ~extra_attrs:
            (Value.return
               [ Vdom.Attr.type_ "password"; Vdom.Attr.class_ "form-control" ])
    | New_password ->
        E.Textbox.string [%here]
          ~extra_attrs:
            (Value.return
               [ Vdom.Attr.type_ "password"; Vdom.Attr.class_ "form-control" ])
end

let form = Form.Typed.Record.make (module T)

let alert_effect =
  let module ChangePassword =
    Nittany_market_frontend_graphql.Queries.ChangePasswordMutation
  in
  let module Client =
    Nittany_market_frontend_graphql.Client.ForQuery (ChangePassword) in
  let alert (s : T.t) =
    let query =
      Client.query
        (ChangePassword.makeVariables ~old_pass:s.current_password
           ~new_pass:s.new_password ())
    in
    Lwt.map
      (fun resp ->
        let success =
          match resp with Client.Success b -> b.change_password | _ -> false
        in
        let msg =
          if success then "Password changed" else "Password change failed"
        in
        ignore (Js_of_ocaml.Dom_html.window##alert (Js_of_ocaml.Js.string msg)))
      query
  in
  Effect_lwt.of_deferred_fun alert

let component =
  let%map.Computation form = form in
  let on_submit = Form.Submit.create ~f:alert_effect () in
  let form_vdom = Form.view_as_vdom form ~on_submit in
  Vdom.Node.div ~attr:(Vdom.Attr.classes [ "py-2"; "px-3" ]) [ form_vdom ]