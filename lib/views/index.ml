open Jingoo

let get request =
  let user_id = Dream.session_field request "user_id" in
  Dream.html
    (Jg_template.from_file "templates/index.jinja"
       ~models:
         [
           ( "user_id",
             match user_id with
             | Some id -> Jg_types.Tstr id
             | None -> Jg_types.Tnull );
           ("csrf_tag", Jg_types.Tstr (Dream.csrf_tag request));
         ])
