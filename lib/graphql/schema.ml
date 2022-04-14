open Graphql_lwt

let user =
  Schema.(
    obj "user" ~fields:(fun _ ->
        [
          field "email"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (p : Models.User.User.t) -> p.email);
        ]))

let schema =
  Schema.(
    schema
      [
        io_field "users"
          ~args:Arg.[]
          ~typ:(non_null (list (non_null user)))
          ~resolve:(fun info () ->
            Lwt_result.ok
              (Dream.sql info.ctx (Models.User.UserRepository.all ())));
      ])