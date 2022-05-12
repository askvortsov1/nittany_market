open Cmdliner

(* DB tools *)

let size = Some 1
let sql_uri = "sqlite3:db.sqlite"

let gen_pool () =
  match Caqti_lwt.connect_pool ?max_size:size (Uri.of_string sql_uri) with
  | Ok pool -> pool
  | Error err -> failwith (Caqti_error.show err)

let run_caqti callback =
  let%lwt result =
    gen_pool ()
    |> Caqti_lwt.Pool.use (fun db ->
           (* The special exception handling is a workaround for
              https://github.com/paurkedal/ocaml-caqti/issues/68. *)
           match%lwt callback db with
           | result -> Lwt.return (Ok result)
           | exception exn -> raise exn)
  in
  Caqti_lwt.or_fail result

(* Lib Wrappers *)

let start () =
  Dream.run ~error_handler:Nittany_market.Router.custom_error_handler
  @@ Dream.logger
  @@ Dream.sql_pool sql_uri
  @@ Dream.sql_sessions
  @@ Dream.router Nittany_market.Router.routes

let migrate_up () =
  Lwt_main.run (run_caqti Nittany_market.Migrations.migrate_up)

let migrate_down () =
  Lwt_main.run (run_caqti Nittany_market.Migrations.migrate_down)

let init_db () = Lwt_main.run (run_caqti Nittany_market.Csv.run_load)

(* Commands *)

let run_cmd =
  let doc = "run the Nittany Market server" in
  let man = [ `S Manpage.s_description; `P "b" ] in
  let info = Cmd.info "run" ~doc ~man in
  Cmd.v info Term.(const start $ const ())

let migrate_up_cmd =
  let doc = "run database migrations" in
  let man = [ `S Manpage.s_description; `P "b" ] in
  let info = Cmd.info "migrate:up" ~doc ~man in
  Cmd.v info Term.(const migrate_up $ const ())

let migrate_down_cmd =
  let doc = "undo database migrations" in
  let man = [ `S Manpage.s_description; `P "b" ] in
  let info = Cmd.info "migrate:down" ~doc ~man in
  Cmd.v info Term.(const migrate_down $ const ())

let init_db_cmd =
  let doc = "insert test data into the database" in
  let man = [ `S Manpage.s_description; `P "b" ] in
  let info = Cmd.info "init_data" ~doc ~man in
  Cmd.v info Term.(const init_db $ const ())

(* Main Command Group *)

let main_cmd =
  let doc = "database management commands for Nittany Market" in
  let man =
    [ `S Manpage.s_bugs; `P "Email bug reports to <alexander@psu.edu>." ]
  in
  let info = Cmd.info "nmdb" ~version:"%‌%v1.0.0%%" ~doc ~man in
  Cmd.group info [ run_cmd; migrate_up_cmd; migrate_down_cmd; init_db_cmd ]

let main () = exit (Cmd.eval main_cmd)
let () = main ()
