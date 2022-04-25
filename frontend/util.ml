open! Core
open! Bonsai_web

let product_path pid = Printf.sprintf "/products/%d" pid
let category_path cname = Printf.sprintf "/browse/%s" cname

let date_of_epoch stamp =
  let default_stamp = match stamp with Some s -> s | None -> 0 in
  let stamp_span = Core_private.Span_float.of_int_sec default_stamp in
  let then_time = Time.add Time.epoch stamp_span in
  Date.of_time then_time ~zone:Core_private.Time_zone.utc

let listing_expired = function
  | None -> false
  | Some stamp ->
      let then_date = date_of_epoch (Some stamp) in
      let now = Date.today ~zone:Core_private.Time_zone.utc in
      Date.(then_date < now)
