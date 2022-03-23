module LoadCsv (M : Models.Model_intf.Model) = struct
  let load ?(transform = fun x -> x) file_name
      (module Db : Caqti_lwt.CONNECTION) =
    let module CsvUtil = Csvfields.Csv.Record (M) in
    let module Repo = Models.Model_intf.Make_ModelRepository (M) in
    let data = CsvUtil.csv_load file_name in
    Lwt_list.iter_s
      (fun raw_entry ->
        let entry = transform raw_entry in
        Repo.add entry (module Db))
      data
end

module CategoryCsv = LoadCsv (Models.Category.Category)
module ZipcodeInfoCsv = LoadCsv (Models.Zipcodeinfo.ZipcodeInfo)
module AddressCsv = LoadCsv (Models.Address.Address)
module UserCsv = LoadCsv (Models.User.User)
module BuyerCsv = LoadCsv (Models.Buyer.Buyer)
module SellerCsv = LoadCsv (Models.Seller.Seller)
module LocalVendorCsv = LoadCsv (Models.Localvendor.LocalVendor)
module CreditCardCsv = LoadCsv (Models.Creditcard.CreditCard)
module RatingCsv = LoadCsv (Models.Rating.Rating)
module ProductListingCsv = LoadCsv (Models.Productlisting.ProductListing)

let load_funcs =
  [
    CategoryCsv.load "data/Categories.csv";
    ZipcodeInfoCsv.load "data/Zipcode_Info.csv";
    AddressCsv.load "data/Address.csv";
    UserCsv.load
      ~transform:(fun u ->
        { email = u.email; password = Auth.Hasher.hash u.password })
      "data/Users.csv";
    BuyerCsv.load "data/Buyers.csv";
    SellerCsv.load "data/Seller.csv";
    LocalVendorCsv.load "data/Local_Vendors.csv";
    CreditCardCsv.load "data/Credit_Cards.csv";
    RatingCsv.load "data/Ratings.csv";
    ProductListingCsv.load "data/Product_Listing.csv"
  ]

let run_load (module Db : Caqti_lwt.CONNECTION) =
  Lwt_list.iter_s
    (fun (load_func : (module Caqti_lwt.CONNECTION) -> unit Lwt.t) ->
      load_func (module Db))
    load_funcs
