open Jingoo

let get request =
  Dream.html
    (Jg_template.from_file "templates/index.jinja"
       ~models:(Util.jg_models request))
