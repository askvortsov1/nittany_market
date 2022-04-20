open Jingoo

let error_handler =
  Dream.error_template (fun error _debug_dump suggested_response ->
      match error.request with
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
      | None -> Dream.html "A fatal server error occured.")
