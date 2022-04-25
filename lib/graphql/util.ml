let login req email password =
  let%lwt u = Dream.sql req (Models.User.UserRepository.get email) in
  match u with
  | Some user ->
      if Auth.Hasher.verify user.password password then
        let%lwt () = Dream.set_session_field req "user_id" email in
        Lwt.return true
      else Lwt.return false
  | None -> Lwt.return false

let logout req =
  let%lwt () = Dream.invalidate_session req in
  Lwt.return true

let change_password req old_pass new_pass =
  let uid = Dream.session_field req "user_id" in
  match uid with
  | None -> raise Exn.Forbidden
  | Some uid -> (
      match%lwt Dream.sql req (Models.User.UserRepository.get uid) with
      | None -> raise Exn.Forbidden
      | Some u ->
          if Models.User.User.check_password u old_pass then
            let hashed_new_pass = Auth.Hasher.hash new_pass in
            let new_u = { u with password = hashed_new_pass } in
            let%lwt () =
              Dream.sql req (Models.User.UserRepository.update uid new_u)
            in
            Lwt.return true
          else raise Exn.Unauthorized)

let add_listing req cat title name desc price quantity expires_at =
  let uid = Dream.session_field req "user_id" in
  match uid with
  | None -> raise Exn.Forbidden
  | Some uid ->
      let%lwt max_id =
        Dream.sql req
          (Models.Productlisting.ProductListingRepository.get_max_id ())
      in
      let l =
        {
          Models.Productlisting.ProductListing.category = cat;
          listing_id = max_id + 1;
          seller_email = uid;
          product_name = name;
          product_description = desc;
          title;
          price;
          quantity;
          expires_at;
        }
      in
      let%lwt () =
        Dream.sql req (Models.Productlisting.ProductListingRepository.add l)
      in
      Lwt.return (max_id + 1)
