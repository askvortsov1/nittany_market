module type Query = sig
  type t
  type t_variables

  module Raw : sig
    type t
    type t_variables
  end

  val query : string
  val parse : Raw.t -> t
  val serialize : t -> Raw.t
  val serializeVariables : t_variables -> Raw.t_variables
  val unsafe_fromJson : Yojson.Basic.t -> Raw.t
  val toJson : Raw.t -> Yojson.Basic.t
  val variablesToJson : Raw.t_variables -> Yojson.Basic.t
end

module SerializableQuery (Q : Query) = struct
  include Q

  let t_of_sexp s =
    s |> Sexplib0.Sexp.to_string |> Yojson.Basic.from_string
    |> Q.unsafe_fromJson |> Q.parse

  let sexp_of_t t =
    let t_str = t |> Q.serialize |> Q.toJson |> Yojson.Basic.to_string in
    Sexplib0.Sexp.Atom t_str

  let equal a b = Sexplib0.Sexp.equal (sexp_of_t a) (sexp_of_t b)

  let yojson_of_t_variables vars =
    vars |> serializeVariables |> Q.variablesToJson |> Yojson.Basic.to_string
    |> Yojson.Safe.from_string
end
;;

[%graphql
  {|
  fragment CreditCardFields on credit_card {
    last_four_digits
    expires
    card_type
  }
|}]
;;

[%graphql
  {|
  fragment AddressFields on address {
    zipcode
    street_num
    street_name
  }
|}]
;;

[%graphql
  {|
fragment ProductListingFields on product_listing {
  id
  title
  product_name
  product_description
  price
  quantity
  seller {
    email
  }
  category_name
  reviews {
    buyer_email
    description
  }
}
|}]
;;

[%graphql
  {|
  fragment UserFields on user {
    email
    buyer_profile {
      first_name
      last_name
      gender
      age
      home_address {
        ...AddressFields
      }
      billing_address {
        ...AddressFields
      }
    }
    seller_profile {
      account_number
      routing_number
      balance
    }
    vendor_profile {
      business_name
      business_address {
        ...AddressFields
      }
      customer_service_number
    }
    credit_cards {
      ...CreditCardFields
    }
  }
|}]
;;

[%graphql
  {|
  query PayloadQuery {
    payload {
      current_user {
        ...UserFields
      }
      csrf_token
    }
  }
|}]
;;

[%graphql {|
  query UsersQuery {
    users {
      email
    }
  }
|}];;

[%graphql
  {|
  query ProductListingQuery($id: Int!) {
    product_listing(id: $id) {
      ...ProductListingFields
    }
  }
|}]
;;

[%graphql
  {|
  query MyListingsQuery {
    my_listings {
      ...ProductListingFields
    }
  }
|}]
;;

[%graphql
  {|
  query CategoryQuery($id: String!) {
    category(id: $id) {
      name
      parent {
        name
      }
      children {
        name
      }
      listings {
        ...ProductListingFields
      }
    }
  }
|}]
;;

[%graphql
  {|
  query CategoriesQuery {
    categories {
      name
      parent {
        name
      }
      children {
        name
      }
    }
  }
|}]
;;

[%graphql
  {|
  mutation LoginMutation($email: String!, $password: String!) {
    login(email: $email, password: $password)
  }
|}]
;;

[%graphql {|
  mutation LogoutMutation {
    logout
  }
|}];;

[%graphql
  {|
  mutation ChangePasswordMutation($old_pass: String!, $new_pass: String!) {
    change_password(old_password: $old_pass, new_password: $new_pass)
  }
|}]
;;

[%graphql
{|
mutation AddListingMutation($title: String!, $product_name: String!, $product_description: String!, $price: String!, $quantity: Int!, $category_name: String!) {
  add_listing(
    title: $title
    product_name: $product_name
    product_description: $product_description
    price: $price
    quantity: $quantity
    category: $category_name
  ) @ppxAs(type: int)
}
|}]
;;