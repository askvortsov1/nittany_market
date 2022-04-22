module ForQuery (Q : Queries.Query): sig
    val query: ?url:Uri.t -> Q.t_variables -> (Cohttp.Code.status_code * Q.t option) Lwt.t
end