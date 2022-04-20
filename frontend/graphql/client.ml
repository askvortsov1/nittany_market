open Lwt.Infix

let url = Uri.of_string "http://localhost:8080/graphql"

module ForQuery (Q : Queries.Query) = struct
  type query_body = { query : string } [@@deriving yojson]

  let create_body q =
    let yojson = query_body_to_yojson { query = q } in
    let json = Yojson.Safe.to_string yojson in
    Cohttp_lwt.Body.of_string json

  let query ?(url=url) () =
    Cohttp_lwt_jsoo.Client.post
      ~headers:(Cohttp.Header.init_with "Content-Type" "application/json")
      ~body:(create_body Q.query) url
    >>= fun (resp, raw_body) ->
    let model_lwt =
      match resp.status with
      | `OK | `Accepted ->
          let body_str_lwt = Cohttp_lwt.Body.to_string raw_body in
          body_str_lwt >|= fun body_str ->
          let body_json = Yojson.Basic.from_string body_str in
          let body_unsafe = Q.unsafe_fromJson body_json in
          let body = Q.parse body_unsafe in
          Some body
      | _ -> Lwt.return None
    in
    model_lwt >|= fun model -> (resp.status, model)
end

module PayloadClient = ForQuery(Queries.PayloadQuery)