open Jingoo


let handle_general req suggested_response =
  match req with
  | Some req ->
      Dream.html
        (Jg_template.from_file "templates/error.jinja"
           ~models:
             (Util.jg_models
                ~other_models:
                  [
                    ( "error",
                      Jg_types.Tstr
                        (Dream.status_to_string
                           (Dream.status suggested_response)) );
                  ]
                req))
  | None -> Dream.html "A fatal server error occured."

let handle_string req suggested_response _str =
  handle_general req suggested_response

let handle_exn req suggested_response (err: exn) =
  match err with
  | Nmgraphql.Exn.Unauthorized -> Dream.respond ~status:`Unauthorized ""
  | Nmgraphql.Exn.Forbidden -> Dream.respond ~status:`Forbidden ""
  | _ -> Dream.log "EFDSFDS"; handle_general req suggested_response

let error_handler =
  Dream.error_template (fun error _debug_dump suggested_response ->
      match error.condition with
      | `Exn exn -> handle_exn error.request suggested_response exn
      | `Response resp -> Lwt.return resp
      | `String str -> handle_string error.request suggested_response str)
