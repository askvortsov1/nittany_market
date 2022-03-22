let post request = 
  let%lwt () = Dream.set_session_field request "user_id" "hello@nsu.edu" in
  Dream.redirect request "/"