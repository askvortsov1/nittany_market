open Lwt.Infix

let url = Uri.of_string "/graphql"

let string_of_sexp = Sexplib0.Sexp.to_string
let sexp_of_string str = Sexplib0.Sexp.Atom str

module ForQuery (Q : Queries.Query) = struct
  module SerializableQ = Queries.SerializableQuery(Q)

  type response = 
    | Success of SerializableQ.t
    | Unauthorized
    | Forbidden
    | NotFound
    | TooManyRequests
  | OtherError of string
  [@@deriving sexp]

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
    let resp_lwt =
      let body_str_lwt = Cohttp_lwt.Body.to_string raw_body in
      body_str_lwt >|= fun body_str ->
      match resp.status with
      | #Cohttp.Code.success_status ->
          let full_body_json = Yojson.Basic.from_string body_str in
          let body_json = Yojson.Basic.Util.member "data" full_body_json in
          let body_unsafe = Q.unsafe_fromJson body_json in
          let body = Q.parse body_unsafe in
          Success body
      | `Unauthorized -> Unauthorized
      | `Forbidden -> Forbidden
      | `Not_found -> NotFound
      | `Too_many_requests -> TooManyRequests
      | #Cohttp.Code.server_error_status -> OtherError body_str
      | #Cohttp.Code.redirection_status -> OtherError body_str
      | #Cohttp.Code.informational_status -> OtherError body_str
      | #Cohttp.Code.client_error_status -> OtherError body_str
      (* This might not be correct... *)
      | `Code _ -> OtherError body_str
    in
    resp_lwt
end
