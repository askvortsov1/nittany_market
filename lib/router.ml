let routes : Dream.route list =
  [
    Dream.any "/graphql"  (Dream.graphql Lwt.return Nmgraphql.Schema.schema);
    Dream.get "/graphiql" (Dream.graphiql "/graphql");
    Dream.get "/" Views.Index.get;
    Dream.get "/login" Views.Login.get;
    Dream.post "/login" Views.Login.post;
    Dream.post "/logout" Views.Logout.post;
  ]

let custom_error_handler = Views.Error.error_handler
