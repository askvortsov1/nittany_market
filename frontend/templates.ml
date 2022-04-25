open! Core
open Bonsai_web

let skeleton ?(nav = Vdom.Node.none) title body =
  Vdom.Node.div
    ~attr:(Vdom.Attr.classes [ "container"; "min-vh-100" ])
    [
      Vdom.Node.div
        ~attr:(Vdom.Attr.classes [ "row"; "min-vh-100" ])
        [
          Vdom.Node.div
            ~attr:(Vdom.Attr.classes [ "col-md-12"; "min-vh-100" ])
            [
              Vdom.Node.div
                ~attr:(Vdom.Attr.classes [ "p-4"; "text-center"; "bg-primary" ])
                [
                  Vdom.Node.h1
                    ~attr:(Vdom.Attr.classes [ "mb-3"; "text-light" ])
                    [ title ];
                ];
              nav;
              Vdom.Node.div
                ~attr:
                  (Vdom.Attr.classes
                     [ "container-sm"; "bg-white"; "min-vh-100" ])
                [ body ];
            ];
        ];
    ]

let card ?(extra_classes = []) title body =
  Vdom.Node.div ~attr:(Vdom.Attr.class_ "card")
    [
      Vdom.Node.div
        ~attr:(Vdom.Attr.class_ "card-body")
        [
          Vdom.Node.h5
            ~attr:(Vdom.Attr.classes ("card-title" :: extra_classes))
            [ title ];
          body;
        ];
    ]

let not_found =
  Vdom.Node.div
    [
      Vdom.Node.p [ Vdom.Node.text "Not Found" ];
      Vdom.Node.a
        ~attr:
          (Vdom.Attr.many
             [ Vdom.Attr.href "/"; Vdom.Attr.classes [ "btn"; "btn-primary" ] ])
        [ Vdom.Node.text "Return To Home" ];
    ]

let display_opt component v =
  match v with None -> Vdom.Node.none | Some v -> component v

let bullet key value =
  Vdom.Node.li
    [ Vdom.Node.strong [ Vdom.Node.textf "%s: " key ]; Vdom.Node.text value ]