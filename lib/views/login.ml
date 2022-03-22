let get request = Dream.redirect request "/"

let post request =
  match%lwt Dream.form request with
  | `Ok [ ("email", email); ("password", password) ] ->
      let%lwt u = Dream.sql request (Models.User.UserRepository.get email) in
      (match u with
      | Some user ->
          if Auth.Hasher.verify user.password password then
            let%lwt () = Dream.set_session_field request "user_id" email in
            Dream.redirect request "/"
          else Dream.empty `Unauthorized
      | None -> Dream.empty `Unauthorized)
  | _ -> Dream.empty `Bad_Request
