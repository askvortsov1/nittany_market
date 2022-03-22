let routes : Dream.route list = [
  Dream.get "/" Views.Index.get;
  Dream.post "/login" Views.Login.post;
  Dream.post "/logout" Views.Logout.post;
]
