let login req email password =
  let%lwt u = Dream.sql req (Models.User.UserRepository.get email) in
  match u with
  | Some user ->
      if Auth.Hasher.verify user.password password then
        let%lwt () = Dream.set_session_field req "user_id" email in
        Lwt.return true
      else Lwt.return false
  | None -> Lwt.return false
