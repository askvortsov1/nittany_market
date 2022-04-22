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

let payload =
  Schema.(
    obj "payload" ~fields:(fun _ ->
        [
          io_field "current_user"
            ~args:Arg.[]
            ~typ:user
            ~resolve:(fun info () ->
              let uid = Dream.session_field info.ctx "user_id" in
              match uid with
              | Some uid ->
                  Lwt_result.ok
                    (Dream.sql info.ctx (Models.User.UserRepository.get uid))
              | None -> Lwt_result.return None);
          field "csrf_token"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun info () -> Dream.csrf_token info.ctx);
        ]))

let schema =
  Schema.(
    schema
      [
        field "payload" ~args:Arg.[] ~typ:(non_null payload) ~resolve:(fun _ _ -> ());
        io_field "users"
          ~args:Arg.[]
          ~typ:(non_null (list (non_null user)))
          ~resolve:(fun info () ->
            Lwt_result.ok
              (Dream.sql info.ctx (Models.User.UserRepository.all ())));
      ]
      ~mutations:
        [
          io_field "login" ~typ:(non_null bool)
            ~args:
              Arg.
                [
                  arg "email" ~typ:(non_null string);
                  arg "password" ~typ:(non_null string);
                ]
            ~resolve:(fun info () email password ->
              Lwt_result.ok (Util.login info.ctx email password));
        ])
