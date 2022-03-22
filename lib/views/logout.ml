let post request =
  let%lwt () = Dream.invalidate_session request in
  Dream.redirect request "/"