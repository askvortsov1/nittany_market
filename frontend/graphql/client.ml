open Lwt.Infix

let url = Uri.of_string "http://localhost:8080/graphql"

module ForQuery (Q : Queries.Query) = struct
  module SerializableQ = Queries.SerializableQuery(Q)
  type query_body = { query : string; variables : SerializableQ.t_variables }
  [@@deriving yojson_of]

  let create_body q vars =
    let yojson = yojson_of_query_body { query = q; variables = vars } in
    let json = Yojson.Safe.to_string yojson in
    Cohttp_lwt.Body.of_string json

  let query ?(url = url) vars =
    Cohttp_lwt_jsoo.Client.post
      ~headers:(Cohttp.Header.init_with "Content-Type" "application/json")
      ~body:(create_body Q.query vars) url
    >>= fun (resp, raw_body) ->
    let model_lwt =
      match resp.status with
      | `OK | `Accepted ->
          let body_str_lwt = Cohttp_lwt.Body.to_string raw_body in
          body_str_lwt >|= fun body_str ->
          let full_body_json = Yojson.Basic.from_string body_str in
          let body_json = Yojson.Basic.Util.member "data" full_body_json in
          let body_unsafe = Q.unsafe_fromJson body_json in
          let body = Q.parse body_unsafe in
          Some body
      | _ -> Lwt.return None
    in
    model_lwt >|= fun model -> (resp.status, model)
end
