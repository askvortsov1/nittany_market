let routes : Dream.route list =
  [
    Dream.any "/graphql"  (Dream.graphql Lwt.return Nmgraphql.Schema.schema);
    Dream.get "/graphiql" (Dream.graphiql "/graphql");
    Dream.get "/static/**" (Dream.static "assets");
    Dream.get "/**" Views.Index.get;
  ]

let custom_error_handler = Views.Error.error_handler
