module ForQuery (Q : Queries.Query): sig
    type response = 
      | Success of Q.t
      | Unauthorized
      | Forbidden
      | NotFound
      | TooManyRequests
      | OtherError of string
    [@@deriving sexp]

    val query: ?url:Uri.t -> Q.t_variables -> response Lwt.t
end