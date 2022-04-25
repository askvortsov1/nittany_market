module Hash = Argon2.ID

let hash password = 
  let hash_len = 16 in
  let salt_len = 16 in
  let t_cost = 2 in
  let m_cost = 50 * 1024 in
  let parallelism = 4 in
  let salt = Dream.random(salt_len) in
  let encoded_len =
    Argon2.encoded_len
      ~t_cost
      ~m_cost
      ~parallelism
      ~salt_len
      ~hash_len
      ~kind:ID
    in

  let result =
    Hash.hash_encoded
      ~t_cost
      ~m_cost
      ~parallelism
      ~pwd:password
      ~salt
      ~hash_len
      ~encoded_len
  in match result with
  | Result.Ok encoded -> Hash.encoded_to_string encoded
  | Result.Error e -> failwith (Printf.sprintf "Error Hashing: %s" (Argon2.ErrorCodes.message e))

let verify hash password =
  let result = Argon2.verify ~encoded:hash ~pwd:password ~kind:ID in
  match result with
  | Result.Ok matches -> matches
  | Result.Error _ -> false