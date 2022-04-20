let get_uri () =
  let open Js_of_ocaml in
  Dom_html.window##.location##.href |> Js.to_string |> Uri.of_string
;;

let set_uri uri =
  let open Js_of_ocaml in
  Dom_html.window##.location##.href = Js.string (Uri.to_string uri)

let set_path path =
  let curr_uri = get_uri () in
  let new_uri = Uri.with_path curr_uri path in
  set_uri new_uri