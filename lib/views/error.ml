open Jingoo

let error_handler =
  Dream.error_template (fun _error _debug_dump suggested_response ->
      Dream.html
        (Jg_template.from_file "templates/error.jinja"
           ~models:
             [
               ( "error",
                 Jg_types.Tstr
                   (Dream.status_to_string (Dream.status suggested_response)) );
             ]))
