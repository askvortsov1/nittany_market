open Caqti_request.Infix
module type DB = Caqti_lwt.CONNECTION

module R = Caqti_request
module T = Caqti_type

type migration = {
  up : (module DB) -> unit Lwt.t;
  down : (module DB) -> unit Lwt.t;
}

let mig_exec str =
  let query = T.unit -->. T.unit @:- str in
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
)|};
      down = mig_exec {|DROP TABLE dream_session|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE category (
  category_name TEXT PRIMARY KEY,
  parent_category TEXT,
  FOREIGN KEY (parent_category) REFERENCES category (category_name)
)|};
      down = mig_exec {|DROP TABLE category|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE zipcode_info (
  zipcode TEXT PRIMARY KEY,
  city TEXT,
  state_id TEXT,
  population INTEGER,
  density FLOAT,
  county_name TEXT,
  timezone TEXT
)|};
      down = mig_exec {|DROP TABLE zipcode_info|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE address (
  address_id TEXT PRIMARY KEY,
  zipcode TEXT,
  street_num INTEGER,
  street_name TEXT,
  FOREIGN KEY (zipcode) REFERENCES zipcode_info (zipcode)
)|};
      down = mig_exec {|DROP TABLE address|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE user (
  email TEXT PRIMARY KEY,
  password TEXT
)|};
      down = mig_exec {|DROP TABLE user|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE buyer (
  email TEXT PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  gender TEXT,
  age INTEGER,
  home_address_id TEXT,
  billing_address_id TEXT,
  FOREIGN KEY (email) REFERENCES user (email),
  FOREIGN KEY (home_address_id) REFERENCES address (address_id),
  FOREIGN KEY (billing_address_id) REFERENCES address (address_id)
)|};
      down = mig_exec {|DROP TABLE buyer|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE seller (
  email TEXT PRIMARY KEY,
  routing_number TEXT,
  account_number INT,
  balance INT,
  FOREIGN KEY (email) REFERENCES user (email)
)|};
      down = mig_exec {|DROP TABLE seller|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE localvendor (
  email TEXT PRIMARY KEY,
  business_number TEXT,
  business_address_id TEXT,
  customer_service_number TEXT,
  FOREIGN KEY (email) REFERENCES user (email)
)|};
      down = mig_exec {|DROP TABLE localvendor|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE creditcard (
  credit_card_num TEXT PRIMARY KEY,
  card_code INT,
  expire_month INT,
  expire_year INT,
  card_type TEXT,
  owner_email TEXT,
  FOREIGN KEY (owner_email) REFERENCES user (email)
)|};
      down = mig_exec {|DROP TABLE creditcard|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE rating (
  buyer_email TEXT,
  seller_email TEXT,
  date TEXT,
  rating INT,
  rating_desc TEXT,
  FOREIGN KEY (buyer_email) REFERENCES user (buyer_email),
  FOREIGN KEY (seller_email) REFERENCES user (seller_email)
)|};
      down = mig_exec {|DROP TABLE rating|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE productlisting (
  listing_id INT PRIMARY KEY,
  seller_email TEXT,
  category TEXT,
  title TEXT,
  product_name TEXT,
  product_description TEXT,
  price TEXT,
  quantity INTEGER,
  FOREIGN KEY (seller_email) REFERENCES user (email),
  FOREIGN KEY (category) REFERENCES category (category_name)
)|};
      down = mig_exec {|DROP TABLE productlisting|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE orders (
  transaction_id INT PRIMARY KEY,
  seller_email TEXT,
  listing_id INT,
  buyer_email TEXT,
  date TEXT,
  quantity INT,
  balance INT,
  FOREIGN KEY (seller_email) REFERENCES user (email),
  FOREIGN KEY (listing_id) REFERENCES productlisting (listing_id),
  FOREIGN KEY (buyer_email) REFERENCES user (email)
)|};
      down = mig_exec {|DROP TABLE orders|};
    };
    {
      up =
        mig_exec
          {|
CREATE TABLE review (
  buyer_email TEXT,
  seller_email TEXT,
  listing_id INT,
  review_desc TEXT,
  FOREIGN KEY (seller_email) REFERENCES user (email),
  FOREIGN KEY (listing_id) REFERENCES productlisting (listing_id),
  FOREIGN KEY (buyer_email) REFERENCES user (email)
)|};
      down = mig_exec {|DROP TABLE review|};
    };
    {
      up =
        mig_exec
          {|
ALTER TABLE productlisting ADD expires_at INTEGER|};
      down = mig_exec {|ALTER TABLE productlisting DROP COLUMN expires_at|};
    };
  ]

let migrate_up (module Db : DB) =
  Lwt_list.iter_s (fun mig -> mig.up (module Db)) migrations

let migrate_down (module Db : DB) =
  Lwt_list.iter_s (fun mig -> mig.down (module Db)) (List.rev migrations)
