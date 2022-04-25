open Bonsai_web
open Bonsai.Let_syntax

let get_uri () =
  let open Js_of_ocaml in
  Dom_html.window##.location##.href |> Js.to_string |> Uri.of_string

let uri_atom = Bonsai.Var.create (get_uri ())

let set_uri uri =
  let open Js_of_ocaml in
  let str_uri = Js.string (Uri.to_string uri) in
  Dom_html.window##.history##pushState Js.null str_uri (Js.Opt.return str_uri);
  Bonsai.Var.set uri_atom uri

let curr_path = uri_atom |> Bonsai.Var.get |> Uri.path |> Value.return
let empty = Bonsai.const @@ Vdom.Node.text ""

let link ?(attrs = []) ?(children = empty) uri =
  let%sub children = children in
  let%arr children = children in
  let set_uri = Effect.of_sync_fun (fun new_uri -> set_uri new_uri) in
  let link_attrs =
    [
      Vdom.Attr.href (Uri.to_string uri);
      Vdom.Attr.on_click (fun e ->
          Js_of_ocaml.Dom.preventDefault e;
          set_uri uri);
    ]
  in
  Vdom.Node.a ~attr:(Vdom.Attr.many (attrs @ link_attrs)) [ children ]

let path_link ?(attrs = []) ?(children = empty) path =
  let curr = get_uri () in
  let uri = Uri.with_path curr path in
  link ~attrs ~children uri

let router routes =
  let uri = Bonsai.Var.value uri_atom in
  let path = Value.map uri ~f:Uri.path in
  routes path
