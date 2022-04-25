open Graphql_lwt

let address =
  Schema.(
    obj "address" ~fields:(fun _ ->
        [
          field "zipcode"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (p : Models.Address.Address.t) -> p.zipcode);
          field "street_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (p : Models.Address.Address.t) -> p.street_name);
          field "street_num"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _ (p : Models.Address.Address.t) -> p.street_num);
        ]))

let buyer_profile =
  Schema.(
    obj "buyer_profile" ~fields:(fun _ ->
        [
          field "first_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.first_name);
          field "last_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.last_name);
          field "gender"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.gender);
          field "age"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _ (bp : Models.Buyer.Buyer.t) -> bp.age);
          io_field "home_address"
            ~args:Arg.[]
            ~typ:address
            ~resolve:(fun info (bp : Models.Buyer.Buyer.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Address.AddressRepository.get bp.home_address_id)));
          io_field "billing_address"
            ~args:Arg.[]
            ~typ:address
            ~resolve:(fun info (bp : Models.Buyer.Buyer.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Address.AddressRepository.get bp.billing_address_id)));
        ]))

let seller_profile =
  Schema.(
    obj "seller_profile" ~fields:(fun _ ->
        [
          field "routing_number"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (s : Models.Seller.Seller.t) -> s.routing_number);
          field "account_number"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _ (s : Models.Seller.Seller.t) -> s.account_number);
          field "balance"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _ (s : Models.Seller.Seller.t) -> s.balance);
        ]))

let vendor_profile =
  Schema.(
    obj "vendor_profile" ~fields:(fun _ ->
        [
          field "business_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (v : Models.Localvendor.LocalVendor.t) ->
              v.business_name);
          field "customer_service_number"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (v : Models.Localvendor.LocalVendor.t) ->
              v.customer_service_number);
          io_field "business_address"
            ~args:Arg.[]
            ~typ:address
            ~resolve:(fun info (v : Models.Localvendor.LocalVendor.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Address.AddressRepository.get v.business_address_id)));
        ]))

let credit_card =
  Schema.(
    obj "credit_card" ~fields:(fun _ ->
        [
          field "card_type"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (cc : Models.Creditcard.CreditCard.t) ->
              cc.card_type);
          field "expires"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (cc : Models.Creditcard.CreditCard.t) ->
              Printf.sprintf "%.2d/%.2d" cc.expire_month cc.expire_year);
          field "last_four_digits"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (cc : Models.Creditcard.CreditCard.t) ->
              let len = String.length cc.credit_card_num in
              String.sub cc.credit_card_num (len - 4) 4);
        ]))

let user =
  Schema.(
    obj "user" ~fields:(fun _ ->
        [
          field "email"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (u : Models.User.User.t) -> u.email);
          io_field "buyer_profile"
            ~args:Arg.[]
            ~typ:buyer_profile
            ~resolve:(fun info (u : Models.User.User.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx (Models.Buyer.BuyerRepository.get u.email)));
          io_field "seller_profile"
            ~args:Arg.[]
            ~typ:seller_profile
            ~resolve:(fun info (u : Models.User.User.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Seller.SellerRepository.get u.email)));
          io_field "vendor_profile"
            ~args:Arg.[]
            ~typ:vendor_profile
            ~resolve:(fun info (u : Models.User.User.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Localvendor.LocalVendorRepository.get u.email)));
          io_field "credit_cards"
            ~args:Arg.[]
            ~typ:(non_null (list (non_null credit_card)))
            ~resolve:(fun info (u : Models.User.User.t) ->
              let res =
                Dream.sql info.ctx
                  (Models.Creditcard.CreditCardRepository.query_owner_email
                     u.email)
              in
              Lwt_result.ok res);
        ]))

let review =
  Schema.(
    obj "review" ~fields:(fun _ ->
        [
          field "description"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (r : Models.Review.Review.t) -> r.review_desc);
          field "buyer_email"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _ (r : Models.Review.Review.t) -> r.buyer_email);
        ]))

let product_listing =
  Schema.(
    obj "product_listing" ~fields:(fun _ ->
        [
          field "id"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.listing_id);
          field "title"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.title);
          field "product_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.product_name);
          field "product_description"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.product_description);
          field "price"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.price);
          field "quantity"
            ~args:Arg.[]
            ~typ:(non_null int)
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.quantity);
          field "category_name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.category);
          field "expires_at"
            ~args:Arg.[]
            ~typ:int
            ~resolve:(fun _info (pl : Models.Productlisting.ProductListing.t) ->
              pl.expires_at);
          field "is_seller"
            ~args:Arg.[]
            ~typ:(non_null bool)
            ~resolve:(fun info (pl : Models.Productlisting.ProductListing.t) ->
              let uid = Dream.session_field info.ctx "user_id" in
              match uid with
              | None -> false
              | Some uid -> String.equal pl.seller_email uid);
          io_field "seller"
            ~args:Arg.[]
            ~typ:user
            ~resolve:(fun info (pl : Models.Productlisting.ProductListing.t) ->
              let res =
                Dream.sql info.ctx
                  (Models.User.UserRepository.get pl.seller_email)
              in
              Lwt_result.ok res);
          io_field "reviews"
            ~args:Arg.[]
            ~typ:(non_null (list (non_null review)))
            ~resolve:(fun info (r : Models.Productlisting.ProductListing.t) ->
              let res =
                Dream.sql info.ctx
                  (Models.Review.ReviewRepository.query_listing_id r.listing_id)
              in
              Lwt_result.ok res);
        ]))

let category =
  Schema.(
    obj "category" ~fields:(fun category ->
        [
          field "name"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun _info (c : Models.Category.Category.t) ->
              c.category_name);
          io_field "listings"
            ~args:Arg.[]
            ~typ:(non_null (list (non_null product_listing)))
            ~resolve:(fun info (c : Models.Category.Category.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Productlisting.ProductListingRepository
                    .query_category c.category_name)));
          io_field "parent"
            ~args:Arg.[]
            ~typ:category
            ~resolve:(fun info (c : Models.Category.Category.t) ->
              Lwt_result.ok
                (Dream.sql info.ctx
                   (Models.Category.CategoryRepository.get c.parent_category)));
          io_field "children"
            ~args:Arg.[]
            ~typ:(non_null (list (non_null category)))
            ~resolve:(fun info (c : Models.Category.Category.t) ->
              let res =
                Dream.sql info.ctx
                  (Models.Category.CategoryRepository.query_parent_category
                     c.category_name)
              in
              Lwt_result.ok res);
        ]))

let payload =
  Schema.(
    obj "payload" ~fields:(fun _ ->
        [
          io_field "current_user"
            ~args:Arg.[]
            ~typ:user
            ~resolve:(fun info () ->
              let uid = Dream.session_field info.ctx "user_id" in
              match uid with
              | Some uid ->
                  Lwt_result.ok
                    (Dream.sql info.ctx (Models.User.UserRepository.get uid))
              | None -> Lwt_result.return None);
          field "csrf_token"
            ~args:Arg.[]
            ~typ:(non_null string)
            ~resolve:(fun info () -> Dream.csrf_token info.ctx);
        ]))

let schema =
  Schema.(
    schema
      [
        field "payload"
          ~args:Arg.[]
          ~typ:(non_null payload)
          ~resolve:(fun _ _ -> ());
        io_field "users"
          ~args:Arg.[]
          ~typ:(non_null (list (non_null user)))
          ~resolve:(fun info () ->
            Lwt_result.ok
              (Dream.sql info.ctx (Models.User.UserRepository.all ())));
        io_field "category"
          ~args:Arg.[ arg "id" ~typ:(non_null string) ]
          ~typ:category
          ~resolve:(fun info () name ->
            Lwt_result.ok
              (Dream.sql info.ctx (Models.Category.CategoryRepository.get name)));
        io_field "product_listing"
          ~args:Arg.[ arg "id" ~typ:(non_null int) ]
          ~typ:product_listing
          ~resolve:(fun info () pid ->
            Lwt_result.ok
              (Dream.sql info.ctx
                 (Models.Productlisting.ProductListingRepository.get pid)));
        io_field "my_listings" ~args:[]
          ~typ:(non_null (list (non_null product_listing)))
          ~resolve:(fun info () ->
            let uid = Dream.session_field info.ctx "user_id" in
            match uid with
            | Some uid ->
                Lwt_result.ok
                  (Dream.sql info.ctx
                     (Models.Productlisting.ProductListingRepository
                      .query_seller_email uid))
            | None -> Lwt_result.return []);
        io_field "categories"
          ~args:Arg.[]
          ~typ:(non_null (list (non_null category)))
          ~resolve:(fun info () ->
            Lwt_result.ok
              (Dream.sql info.ctx (Models.Category.CategoryRepository.all ())));
      ]
      ~mutations:
        [
          io_field "login" ~typ:(non_null bool)
            ~args:
              Arg.
                [
                  arg "email" ~typ:(non_null string);
                  arg "password" ~typ:(non_null string);
                ]
            ~resolve:(fun info () email password ->
              Lwt_result.ok (Util.login info.ctx email password));
          io_field "logout" ~typ:(non_null bool) ~args:[]
            ~resolve:(fun info () -> Lwt_result.ok (Util.logout info.ctx));
          io_field "change_password" ~typ:(non_null bool)
            ~args:
              Arg.
                [
                  arg "old_password" ~typ:(non_null string);
                  arg "new_password" ~typ:(non_null string);
                ]
            ~resolve:(fun info () old_password new_password ->
              Lwt_result.ok
                (Util.change_password info.ctx old_password new_password));
          io_field "add_listing" ~typ:(non_null int)
            ~args:
              Arg.
                [
                  arg "category" ~typ:(non_null string);
                  arg "title" ~typ:(non_null string);
                  arg "product_name" ~typ:(non_null string);
                  arg "product_description" ~typ:(non_null string);
                  arg "price" ~typ:(non_null string);
                  arg "quantity" ~typ:(non_null int);
                  arg "expires_at" ~typ:int;
                ]
            ~resolve:
              (fun info () cat title name desc price quantity expires_at ->
              Lwt_result.ok
                (Util.add_listing info.ctx cat title name desc price quantity
                   expires_at));
        ])
