module type DB = Caqti_lwt.CONNECTION

module R = Caqti_request
module T = Caqti_type

type migration = {
  up : (module DB) -> unit Lwt.t;
  down : (module DB) -> unit Lwt.t;
}

let mig_exec str =
  let query = R.exec T.unit str in
  fun (module Db : DB) ->
    let%lwt unit_or_error = Db.exec query () in
    Caqti_lwt.or_fail unit_or_error

let migrations =
  [
    {
      up =
        mig_exec
          {|
CREATE TABLE dream_session (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL,
  expires_at REAL NOT NULL,
  payload TEXT NOT NULL
);|};
      down = mig_exec {|DROP TABLE dream_session;|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE user (
  email TEXT,
  password TEXT,
  PRIMARY KEY (email)
);|};
      down = mig_exec {|DROP TABLE user;|};
    };
  ]

let migrate_up (module Db : DB) =
  Lwt_list.iter_s (fun mig -> mig.up (module Db)) migrations

let migrate_down (module Db : DB) =
  Lwt_list.iter_s (fun mig -> mig.down (module Db)) (List.rev migrations)
