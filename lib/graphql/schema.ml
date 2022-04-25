open Graphql_lwt

let address =
  Schema.(
    obj "address" ~fields:(fun _ ->
        [
          field "zipcode"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (p : Models.Address.Address.t) -> p.zipcode);
          field "street_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (p : Models.Address.Address.t) -> p.street_name);
          field "street_num"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _ (p : Models.Address.Address.t) -> p.street_num);
        ]))

let buyer_profile =
  Schema.(
    obj "buyer_profile" ~fields:(fun _ ->
        [
          field "first_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.first_name);
          field "last_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.last_name);
          field "gender"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.gender);
          field "age"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.age);
          io_field "home_address"
            ~args:Arg.[]
            ~typ:address
            ~resolve:(fun info (bp : Models.Buyer.Buyer.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Address.AddressRepository.get bp.home_address_id)));
          io_field "billing_address"
            ~args:Arg.[]
            ~typ:address
            ~resolve:(fun info (bp : Models.Buyer.Buyer.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Address.AddressRepository.get bp.billing_address_id)));
        ]))

let user =
  Schema.(
    obj "user" ~fields:(fun _ ->
        [
          field "email"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (u : Models.User.User.t) -> u.email);
          io_field "buyer_profile"
            ~args:Arg.[]
            ~typ:buyer_profile
            ~resolve:(fun info (u : Models.User.User.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx (Models.Buyer.BuyerRepository.get u.email)));
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
        field "payload"
          ~args:Arg.[]
          ~typ:(non_null payload)
          ~resolve:(fun _ _ -> ());
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
          io_field "logout" ~typ:(non_null bool) ~args:[]
            ~resolve:(fun info () -> Lwt_result.ok (Util.logout info.ctx));
        ])
