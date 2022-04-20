open! Core
open! Bonsai_web
module G = Nittany_market_frontend_graphql

module Action = struct
  type t = Load [@@deriving sexp_of]
end

module T = struct
  module Input = struct
    type t = G.Queries.PayloadQuery.t option
  end

  module Model = struct
    type t = unit [@@deriving sexp]

    let equal _a _b = true
  end

  module Action = struct
    type t = unit [@@deriving sexp]
  end

  module Result = Vdom.Node

  let apply_action ~inject:_ ~schedule_event:_ _input model (_action : Action.t) = model

  let compute ~inject:_ (input: Input.t) (_model : Model.t) =  match input with
  | None -> Vdom.Node.text ""
  | Some data ->
      let token =
        match data.payload with
        | Some payload -> payload.csrf_token
        | None -> "????"
      in
      Vdom.Node.div [ Vdom.Node.text token ]

  let name = Source_code_position.to_string [%here]
end

let component = Bonsai.of_module1 (module T) ~default_model:()
