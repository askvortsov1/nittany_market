open! Core
open! Bonsai_web
module G = Nittany_market_frontend_graphql

module ForQuery (Q : G.Queries.Query) : sig
  val component :
    (Q.t Value.t -> Vdom.Node.t Computation.t) ->
    Q.t_variables ->
    Vdom.Node.t Computation.t
end