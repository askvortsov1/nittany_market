open! Core
open! Bonsai_web
open Bonsai.Let_syntax
module G = Nittany_market_frontend_graphql

let breadcrumbs (all : G.Queries.CategoriesQuery.t_categories array Value.t)
    (category : G.Queries.CategoryQuery.t_category option Value.t) =
  let trail =
    Value.map2 all category ~f:(fun all category ->
        match category with
        | None -> []
        | Some category ->
            let cat_of_name =
              all |> Array.map ~f:(fun c -> (c.name, c)) |> Array.to_list
            in
            let rec build_trail cname =
              let curr =
                Option.bind
                  ~f:(List.Assoc.find cat_of_name ~equal:String.equal)
                  cname
              in
              match curr with
              | Some cat ->
                  (cat.name, cat.name)
                  :: build_trail (Option.map cat.parent ~f:(fun c -> c.name))
              | None -> [ ("All", "") ]
            in
            List.rev (build_trail (Some category.name)))
  in
  let%arr trail = trail in
  let opt_vdom =
    trail
    |> List.map ~f:(fun (cname, cslug) ->
           Route.link_vdom (Util.category_path cslug)
             ~children:(Vdom.Node.text cname))
    |> List.intersperse ~sep:(Vdom.Node.text ">")
    |> List.map ~f:(fun link -> [ link ])
    |> List.reduce_balanced ~f:(fun a b -> a @ b)
    |> Option.map ~f:(fun links -> Vdom.Node.div links)
  in
  match opt_vdom with Some vdom -> vdom | None -> Vdom.Node.none

let display_children ?(root = false) (children : string array) =
  let contents =
    children
    |> Array.map ~f:(fun child ->
           Route.link_vdom (Util.category_path child)
             ~attrs:
               [ Vdom.Attr.classes [ "btn"; "btn-primary"; "mx-2"; "my-1" ] ]
             ~children:(Vdom.Node.text child))
    |> Array.to_list
  in
  if Int.equal (List.length contents) 0 then Vdom.Node.none
  else
    Vdom.Node.div
      ~attr:(Vdom.Attr.classes [ "px-5"; "py-2" ])
      [
        (if root then Vdom.Node.h2 [ Vdom.Node.text "Categories" ]
        else Vdom.Node.h5 [ Vdom.Node.text "Subcategories" ]);
        Vdom.Node.div ~attr:(Vdom.Attr.class_ "row") contents;
      ]

let child_names ?cname (all : G.Queries.CategoriesQuery.t_categories array) =
  match cname with
  | None ->
      all
      |> Array.filter ~f:(fun c -> Option.is_none c.parent)
      |> Array.map ~f:(fun c -> c.name)
  | Some cname -> (
      let category =
        all |> Array.find ~f:(fun c -> String.equal c.name cname)
      in
      match category with
      | Some category ->
          category |> fun (c : G.Queries.CategoriesQuery.t_categories) ->
          c.children |> Array.map ~f:(fun c -> c.name)
      | None -> Array.of_list [])

let product_card (product : G.Queries.ProductListingFields.t) =
  if Util.listing_expired product.expires_at && not product.is_seller then
    Vdom.Node.none
  else
    Vdom.Node.div
      ~attr:(Vdom.Attr.classes [ "col-4"; "px-3"; "py-2" ])
      [
        Templates.card
          (Vdom.Node.text product.title)
          (Vdom.Node.div
             [
               Templates.bullet "Price" product.price;
               Templates.bullet "Quantity" (Int.to_string product.quantity);
               Route.link_vdom
                 (Util.product_path product.id)
                 ~attrs:[ Vdom.Attr.classes [ "btn"; "btn-secondary" ] ]
                 ~children:(Vdom.Node.text "Details");
             ]);
      ]

let display_products (products : G.Queries.ProductListingFields.t array) =
  let product_cards = products |> Array.map ~f:product_card |> Array.to_list in
  Vdom.Node.div
    ~attr:(Vdom.Attr.classes [ "px-5"; "px-3" ])
    [
      Vdom.Node.h2 [ Vdom.Node.text "Products" ];
      (if List.length product_cards > 0 then
       Vdom.Node.div ~attr:(Vdom.Attr.classes [ "row" ]) product_cards
      else Vdom.Node.text "No products found in this exact category.");
    ]

let display_category all
    (category : G.Queries.CategoryQuery.t_category option Value.t) =
  let%sub breadcrumbs = breadcrumbs all category in
  let children =
    Value.map2 all category ~f:(fun all c ->
        match c with
        | Some c -> child_names ~cname:c.name all
        | None -> child_names all)
  in
  let%arr breadcrumbs = breadcrumbs
  and children = children
  and category = category in
  let cname = match category with Some c -> c.name | None -> "" in
  let products =
    match category with Some c -> c.listings | None -> Array.of_list []
  in
  Vdom.Node.div
    [
      breadcrumbs;
      Vdom.Node.hr ();
      Vdom.Node.h2 [ Vdom.Node.text cname ];
      display_children ~root:(Option.is_none category) children;
      Vdom.Node.hr ();
      display_products products;
    ]

let component =
  let deoptionize x = match x with Some x -> x | None -> "" in
  let get_slug path =
    let re = Js_of_ocaml.Regexp.regexp "^/browse/?(.*)/?$" in
    let cid_match = Js_of_ocaml.Regexp.string_match re path 0 in
    cid_match
    |> Option.bind ~f:(fun m -> Js_of_ocaml.Regexp.matched_group m 1)
    |> Option.map ~f:Js_of_ocaml.Url.urldecode
  in

  let module Categories = G.Queries.CategoriesQuery in
  let module PluralLoader = Graphql_loader.ForQuery (Categories) in
  PluralLoader.component ~trigger:Route.curr_path
    (fun all_query ->
      let all = Value.map ~f:(fun data -> data.categories) all_query in
      let module Category = G.Queries.CategoryQuery in
      let module SingleLoader = Graphql_loader.ForQuery (Category) in
      SingleLoader.component ~trigger:Route.curr_path
        (fun category_query ->
          let category =
            Value.map ~f:(fun data -> data.category) category_query
          in
          display_category all category)
        (Value.map
           ~f:(fun v ->
             Category.makeVariables ~id:(deoptionize @@ get_slug v) ())
           Route.curr_path))
    (Value.return @@ Categories.makeVariables ())
