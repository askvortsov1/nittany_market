module OptIntStringable = struct
  type t = int option
  let to_string x = match x with | None -> "" | Some v -> Int.to_string v
  let of_string x = match x with | "" -> None | _ -> Some (int_of_string x)
end

module OptInt = Csvfields.Csv.Atom(OptIntStringable)

module OptFloatStringable = struct
  type t = float option
  let to_string x = match x with | None -> "" | Some v -> Float.to_string v
  let of_string x = match x with | "" -> None | _ -> Some (float_of_string x)
end

module OptFloat = Csvfields.Csv.Atom(OptFloatStringable)