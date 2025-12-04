(* Copyright 2024-2025 Kumar Appaiah *)

(* This file is part of trade_tracker. *)

(* trade_tracker is free software: you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version. *)

(* trade_tracker is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details. *)

(* You should have received a copy of the GNU General Public License
   along with trade_tracker. If not, see <https://www.gnu.org/licenses/>. *)

open Core

let process_file_with_db db percentage flatfee gst =
  let query =
    "select order_num, sum(quantity * peramount), sum(quantity) from \
     raw_transaction_information where brokerage is NULL group by order_num;"
  in
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x :: !rows) query
  then
    if Db_wrapper.run_query db "begin transaction" then (
      let results =
        List.map
          ~f:(fun row ->
            match row with
            | [| Some order_num; Some amount_str; Some quantity_str |] -> (
                let amount = Float.of_string amount_str in
                let quantity = Float.of_string quantity_str in
                let b =
                  if Float.(amount *. percentage /. 100. > flatfee) then
                    flatfee /. quantity
                  else amount *. percentage /. quantity /. 100.
                in
                let update1 =
                  Db_wrapper.run_query db
                    (Printf.sprintf
                       "update raw_transaction_information set brokerage = %f * \
                        quantity where order_num = '%s';"
                       b order_num)
                in
                let update2 =
                  Db_wrapper.run_query db
                    (Printf.sprintf
                       "update raw_transaction_information set gst = %f * \
                        (sebi_turnover_fees + brokerage + exchange_fees) where \
                        order_num = '%s';"
                       (gst /. 100.) order_num)
                in
                if update1 && update2 then
                  "Added brokerage for order " ^ order_num ^ "!"
                else "Error adding brokerage for order " ^ order_num ^ "!")
            | _ -> "ERROR: Invalid row from order aggregation query!")
          !rows
      in
      if Db_wrapper.run_query db "end transaction" then
        String.concat ~sep:"\n" results |> print_endline
      else print_endline "ERROR: Failed to commit transaction!")
    else print_endline "ERROR: Failed to begin transaction!"
  else print_endline "ERROR READING NULL BROKERAGE ROWS!"

let add_missing_brokerages dbname percentage flatfee gst =
  match Db_wrapper.open_database dbname with
  | Some x -> process_file_with_db x percentage flatfee gst
  | None -> print_endline "ERROR OPENING DATABASE!"

let command =
  Command.basic ~summary:"Populate brokerage and GST."
    ~readme:(fun () ->
      "Populates brokerage and GST based on minimum of a flat fee and \
       percentage")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map dbname = anon ("dbname" %: string)
     and percentage = anon ("percentage" %: float)
     and flatfee = anon ("flatfee" %: float)
     and gst = anon ("gst" %: float) in
     fun () -> add_missing_brokerages dbname percentage flatfee gst)

let () = Command_unix.run ~version:"0.1" command
