(* Copyright 2024 Kumar Appaiah *)

(* This file is part of trade_tracker. *)

(* Foobar is free software: you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version. *)

(* Foobar is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details. *)

(* You should have received a copy of the GNU General Public License
   along with Foobar. If not, see <https://www.gnu.org/licenses/>.  *)

open Core

let update_brokerage_gst db order_num brokerage gst =
  Db_wrapper.run_query db
    (Printf.sprintf "update raw_transaction_information set brokerage = %f * quantity where order_num = '%s';" brokerage order_num)
  && Db_wrapper.run_query db
       (Printf.sprintf "update raw_transaction_information set gst = %f * (sebi_turnover_fees + brokerage + exchange_fees) where order_num = '%s';"  (gst /. 100.) order_num)

let get_order_total_amounts db order_num =
  let query = Printf.sprintf "select sum(quantity * peramount),sum(quantity) from raw_transaction_information where order_num = '%s';" order_num in
  let rows = ref []
  in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) query then
    match ((List.hd_exn !rows).(0), (List.hd_exn !rows).(1)) with
    | Some a, Some b -> (Float.of_string a, Float.of_string b)
    | _ -> (0.0, 0.0)
  else
    (0.0, 0.0)

let process_file_with_db db percentage flatfee gst =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) "select distinct order_num from raw_transaction_information where brokerage is NULL;"
  then
    List.map ~f:(fun x -> (match x.(0) with
                           | Some a -> (let (amount, quantity) = get_order_total_amounts db a in
                                        let b = if (Float.(amount *. percentage /. 100. > flatfee)) then flatfee /. quantity else amount *. percentage /. quantity /. 100. in
                                        if update_brokerage_gst db a b gst then
                                          "Added brokerage for order " ^ a ^ "!"
                                        else
                                          "Error adding brokerage for order " ^ a ^ "!"
                                       )
                           | None -> "ERROR getting order quantities!"))
      !rows
    |> String.concat ~sep:"\n"
    |> print_endline
  else
    print_endline "ERROR READING NULL BROKERAGE ROWS!"

let add_missing_brokerages dbname percentage flatfee gst =
  match Db_wrapper.open_database dbname with
  | Some x -> process_file_with_db x percentage flatfee gst
  | None -> print_endline "ERROR OPENING DATABASE!"

let command =
  Command.basic
    ~summary: "Populate brokerage and GST."
    ~readme: (fun () -> "Populates brokerage and GST based on minimum of a flat fee and percentage")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map dbname = anon ("dbname" %: string) and
        percentage = anon ("percentage" %: float) and
        flatfee = anon ("flatfee" %: float) and
        gst = anon ("gst" %: float)
     in
     fun () -> add_missing_brokerages dbname percentage flatfee gst)

let () =
  Command_unix.run ~version:"0.1" command
