(* Copyright 2024-2025 Kumar Appaiah *)

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
   along with Foobar. If not, see <https://www.gnu.org/licenses/>. *)

open Core

let special_scrip_list =
  ["GOLDBEES"; "SETFGOLD"]
  |> List.map ~f:(fun x -> "'" ^ x ^ "'") |> String.concat ~sep:","

let query_onlystocks_base opstr =
  "select S.scrip, B.order_date, S.order_date,sum(n_stocks * S.peramount) as \
   total_value, sum(n_stocks * (S.peramount - B.peramount)) as gain, \
   sum(n_stocks * (B.exchange_fees + B.stamp_duty + B.sebi_turnover_fees + \
   B.brokerage + B.gst) / B.quantity + n_stocks * (S.exchange_fees + \
   S.stamp_duty + S.sebi_turnover_fees + S.brokerage + S.gst) / S.quantity) as \
   total_charges from sale_data join raw_transaction_information as S on S.id \
   = sale_id join raw_transaction_information as B on B.id = buy_id where \
   S.scrip not in (" ^ special_scrip_list ^ ") and \
   julianday(S.order_date) - julianday(B.order_date) " ^ opstr ^ " 365 group by S.scrip"

let query_ltcg_onlystocks =
  query_onlystocks_base ">="

let query_stcg_onlystocks =
  query_onlystocks_base "<"

let query_base opstr =
  "select sum(n_stocks * S.peramount) as total_value, sum(n_stocks * \
   (S.peramount - B.peramount)) as gain, sum(n_stocks * (B.exchange_fees + \
   B.stamp_duty + B.sebi_turnover_fees + B.brokerage + B.gst) / B.quantity + \
   n_stocks * (S.exchange_fees + S.stamp_duty + S.sebi_turnover_fees + \
   S.brokerage + S.gst) / S.quantity) as total_charges from sale_data join \
   raw_transaction_information as S on S.id = sale_id join \
   raw_transaction_information as B on B.id = buy_id where \
   S.scrip not in (" ^ special_scrip_list ^ ") and \
   julianday(S.order_date) - julianday(B.order_date) " ^ opstr ^ " 365 and "

let query_stcg_base =
  query_base "<"

let query_stcg_q1_onlystocks =
  query_stcg_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-04-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-07-01')"

let query_stcg_q2_onlystocks =
  query_stcg_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-07-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-10-01')"

let query_stcg_q3_onlystocks =
  query_stcg_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-10-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-01-01')"

let query_stcg_q4_onlystocks =
  query_stcg_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-01-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-03-16')"

let query_stcg_q5_onlystocks =
  query_stcg_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-03-15') and \
   julianday(S.order_date) < julianday('NEWYEAR-04-01')"

let query_ltcg_base =
  query_base ">="

let query_ltcg_q1_onlystocks =
  query_ltcg_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-04-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-07-01')"

let query_ltcg_q2_onlystocks =
  query_ltcg_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-07-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-10-01')"

let query_ltcg_q3_onlystocks =
  query_ltcg_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-10-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-01-01')"

let query_ltcg_q4_onlystocks =
  query_ltcg_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-01-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-03-16')"

let query_ltcg_q5_onlystocks =
  query_ltcg_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-03-15') and \
   julianday(S.order_date) < julianday('NEWYEAR-04-01')"

let query_onlyspecial opstr =
  "select S.scrip, B.order_date, S.order_date,sum(n_stocks * S.peramount) as \
   total_value, sum(n_stocks * (S.peramount - B.peramount)) as gain, \
   sum(n_stocks * (B.exchange_fees + B.stamp_duty + B.sebi_turnover_fees + \
   B.brokerage + B.gst) / B.quantity + n_stocks * (S.exchange_fees + \
   S.stamp_duty + S.sebi_turnover_fees + S.brokerage + S.gst) / S.quantity) as \
   total_charges from sale_data join raw_transaction_information as S on S.id \
   = sale_id join raw_transaction_information as B on B.id = buy_id where \
   S.scrip in (" ^ special_scrip_list ^ ") and \
   julianday(S.order_date) - julianday(B.order_date) " ^ opstr ^ " 365 group by S.scrip"

let query_stcg_onlyspecial =
  query_onlyspecial "<"

let query_ltcg_onlyspecial =
  query_onlyspecial ">="

let query_onlyspecial_base opstr =
  "select sum(n_stocks * S.peramount) as total_value, sum(n_stocks * \
   (S.peramount - B.peramount)) as gain, sum(n_stocks * (B.exchange_fees + \
   B.stamp_duty + B.sebi_turnover_fees + B.brokerage + B.gst) / B.quantity + \
   n_stocks * (S.exchange_fees + S.stamp_duty + S.sebi_turnover_fees + \
   S.brokerage + S.gst) / S.quantity) as total_charges from sale_data join \
   raw_transaction_information as S on S.id = sale_id join \
   raw_transaction_information as B on B.id = buy_id where \
   S.scrip in (" ^ special_scrip_list ^ ") and \
   julianday(S.order_date) - julianday(B.order_date) " ^ opstr ^ " 365 and "

let query_stcg_onlyspecial_base =
  query_onlyspecial_base "<"

let query_stcg_q1_onlyspecial =
  query_stcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-04-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-07-01')"

let query_stcg_q2_onlyspecial =
  query_stcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-07-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-10-01')"

let query_stcg_q3_onlyspecial =
  query_stcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-10-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-01-01')"

let query_stcg_q4_onlyspecial =
  query_stcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-01-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-03-16')"

let query_stcg_q5_onlyspecial =
  query_stcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-03-15') and \
   julianday(S.order_date) < julianday('NEWYEAR-04-01')"

let query_ltcg_onlyspecial_base =
  query_onlyspecial_base ">="

let query_ltcg_q1_onlyspecial =
  query_ltcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-04-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-07-01')"

let query_ltcg_q2_onlyspecial =
  query_ltcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-07-01') and \
   julianday(S.order_date) < julianday('OLDYEAR-10-01')"

let query_ltcg_q3_onlyspecial =
  query_ltcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('OLDYEAR-10-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-01-01')"

let query_ltcg_q4_onlyspecial =
  query_ltcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-01-01') and \
   julianday(S.order_date) < julianday('NEWYEAR-03-16')"

let query_ltcg_q5_onlyspecial =
  query_ltcg_onlyspecial_base ^
  "julianday(S.order_date) >= julianday('NEWYEAR-03-15') and \
   julianday(S.order_date) < julianday('NEWYEAR-04-01')"

let generate_yearwise_capgains_helper db year quarter query =
  let rows = ref [] in
  let oldyear = Int.to_string year in
  let newyear = Int.to_string (year + 1) in
  let query = Str.(global_replace (regexp "OLDYEAR") oldyear query) in
  let query = Str.(global_replace (regexp "NEWYEAR") newyear query) in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x :: !rows) query
  then
    (match !rows with
     | [ [| Some total_value; Some gain; Some charges |] ] ->
       let gain_num = Float.(of_string gain -. of_string charges) in
       (Printf.sprintf
          "%s total value of consideration: %.2f\n\
           Buy price: %.2f\n\
           %s gain: %.2f\n\
           %s charges: %.2f\n\
           %s net: %.2f\n"
          quarter (Float.of_string total_value)
          Float.(of_string total_value -. of_string gain)
          quarter (Float.of_string gain) quarter (Float.of_string charges) quarter
          gain_num |> print_endline;
        print_endline (Float.to_string gain_num))
     | _ -> print_endline (quarter ^ ": No transactions\n"))
  else print_endline ("Error getting " ^ quarter ^ " transactions!\n")

let generate_yearwise_capgains db year stcg =
  print_endline "STOCKS";
  if stcg then (
    generate_yearwise_capgains_helper db year "Q1" query_stcg_q1_onlystocks;
    generate_yearwise_capgains_helper db year "Q2" query_stcg_q2_onlystocks;
    generate_yearwise_capgains_helper db year "Q3" query_stcg_q3_onlystocks;
    generate_yearwise_capgains_helper db year "Q4" query_stcg_q4_onlystocks;
    generate_yearwise_capgains_helper db year "Q5" query_stcg_q5_onlystocks)
  else (
    generate_yearwise_capgains_helper db year "Q1" query_ltcg_q1_onlystocks;
    generate_yearwise_capgains_helper db year "Q2" query_ltcg_q2_onlystocks;
    generate_yearwise_capgains_helper db year "Q3" query_ltcg_q3_onlystocks;
    generate_yearwise_capgains_helper db year "Q4" query_ltcg_q4_onlystocks;
    generate_yearwise_capgains_helper db year "Q5" query_ltcg_q5_onlystocks);
  print_endline "";
  print_endline "SPECIAL SCRIPS";
  if stcg then (
    generate_yearwise_capgains_helper db year "Q1" query_stcg_q1_onlyspecial;
    generate_yearwise_capgains_helper db year "Q2" query_stcg_q2_onlyspecial;
    generate_yearwise_capgains_helper db year "Q3" query_stcg_q3_onlyspecial;
    generate_yearwise_capgains_helper db year "Q4" query_stcg_q4_onlyspecial;
    generate_yearwise_capgains_helper db year "Q5" query_stcg_q5_onlyspecial)
  else (
    generate_yearwise_capgains_helper db year "Q1" query_ltcg_q1_onlyspecial;
    generate_yearwise_capgains_helper db year "Q2" query_ltcg_q2_onlyspecial;
    generate_yearwise_capgains_helper db year "Q3" query_ltcg_q3_onlyspecial;
    generate_yearwise_capgains_helper db year "Q4" query_ltcg_q4_onlyspecial;
    generate_yearwise_capgains_helper db year "Q5" query_ltcg_q5_onlyspecial)

let process_file_with_db db query =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x :: !rows) query
  then
    List.rev !rows
    |> List.iter ~f:(fun x ->
        match x with
        | [|
          Some scrip;
          Some buy_date;
          Some sell_date;
          Some total_value;
          Some gain;
          Some total_charges;
        |] ->
          print_endline
            (Printf.sprintf
               "Scrip: %s\n\
                Buy date: %s\n\
                Sell date: %s\n\
                Total value: %s\n\
                Gain: %s\n\
                Charges: %s\n"
               scrip buy_date sell_date total_value gain total_charges)
        | _ -> print_endline "Error getting STCG details!")

let process_file dbname year =
  match year with
  | None -> (
      match Db_wrapper.open_database dbname ~readonly:true with
      | Some x ->
        print_endline "STOCKS STCG REPORT";
        process_file_with_db x query_stcg_onlystocks;
        print_endline "STOCKS LTCG REPORT";
        process_file_with_db x query_ltcg_onlystocks;
        print_endline "SPECIAL SCRIPS STCG REPORT";
        process_file_with_db x query_stcg_onlyspecial;
        print_endline "SPECIAL SCRIPS LTCG REPORT";
        process_file_with_db x query_ltcg_onlyspecial;
        if Db_wrapper.close_database x then ()
        else print_endline "Failure closing database!"
      | None -> print_endline "ERROR OPENING DATABASE!")
  | Some y -> (
      match Db_wrapper.open_database dbname with
      | Some x ->
        print_endline (Printf.sprintf "STCG REPORT for %d-%d" y (y + 1));
        generate_yearwise_capgains x y true;
        print_endline (Printf.sprintf "LTCG REPORT for %d-%d" y (y + 1));
        generate_yearwise_capgains x y false;
        if Db_wrapper.close_database x then ()
        else print_endline "Failure closing database!"
      | None -> print_endline "ERROR OPENING DATABASE!")

let command =
  Command.basic ~summary:"Generate capital gains report for stock sales."
    ~readme:(fun () ->
        "Generates details of stock sales and capital gain reports.")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map dbname = anon ("dbname" %: string)
     and year = anon (maybe ("year" %: int)) in
     fun () -> process_file dbname year)

let () = Command_unix.run ~version:"0.1" command
