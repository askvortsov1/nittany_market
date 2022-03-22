let routes : Dream.route list = [
  Dream.get "/" Views.Index.get;
  Dream.get "/login" Views.Login.get;
  Dream.post "/login" Views.Login.post;
  Dream.post "/logout" Views.Logout.post;
]
