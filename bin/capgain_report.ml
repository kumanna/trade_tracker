open Core

(* type stock_sale_info = { *)
(*         scrip : string; *)
(*         buy_price : string; *)
(*         sell_price : string; *)
(*         stcg : bool; *)
(*         sell_date : string; *)
(*         charges : float; *)
(*   } *)

let process_file_with_db db =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) "select sale_id, buy_id, n_stocks from sale_data join raw_transaction_information on raw_transaction_information.id = sale_data.sale_id order by raw_transaction_information.order_date desc, raw_transaction_information.order_num desc" then
    List.iter ~f:(fun x ->
        match x with
        | [|Some sale_id; Some buy_id; Some n_stocks |] ->
           let rows2 = ref [] in
           if Db_wrapper.run_query_callback db ~cb:(fun x -> rows2 := x::!rows2) (Printf.sprintf "select peramount from raw_transaction_information where id in (%s, %s)" sale_id buy_id) then
             match !rows2 with
             | [[|Some sale_price|]; [|Some buy_price|]] ->
                (let rows3 = ref [] in
                 if Db_wrapper.run_query_callback db ~cb:(fun x -> rows3 := x::!rows3) (Printf.sprintf "select (exchange_fees + stamp_duty + sebi_turnover_fees + brokerage + gst) / quantity from raw_transaction_information where id in (%s, %s);" sale_id buy_id) then
                   let total_cost_per_stock =
                     match !rows3 with
                     | [[|Some sell_cost|]; [|Some buy_cost|]] -> (Float.of_string sell_cost) +. (Float.of_string buy_cost)
                     | _ -> 0.0
                   in
                   print_endline (sale_id ^ " and " ^ buy_id ^ ": " ^ n_stocks ^ "," ^ buy_price ^ "," ^ sale_price ^ "," ^ (Float.to_string (total_cost_per_stock *. (Float.of_string n_stocks))))
                   (* match !rows3 with *)
                   (* | [[|Some sell_cost|]; [|Some buy_cost|]] -> print_endline (sale_id ^ "," ^ buy_id ^  "," ^ sale_price ^ "," ^ buy_price ^ "," ^ n_stocks ^ "," ^ sell_cost ^ "," ^ buy_cost ^ "," ^ (List.length !rows3 |> Int.to_string)) *)
                   (* | _ -> print_endline ("Error 4 getting charges for sale and buy transactions " ^ sale_id ^ " and " ^ buy_id ^ ".") *)
                 else
                  print_endline ("Error 2 getting charges for sale and buy transactions " ^ sale_id ^ " and " ^ buy_id ^ "."))
             | _ -> print_endline ("Error 3 getting charges for sale and buy transactions " ^ sale_id ^ " and " ^ buy_id ^ ".")
           else
             print_endline ("Error matching sale and buy transactions " ^ sale_id ^ " and " ^ buy_id ^ ".")

        | _ -> print_endline "Error") !rows
  else
    print_endline "Error";
  if Db_wrapper.close_database db then print_endline "Sale report generated!" else print_endline "Failure during holdings generation!"

let process_file dbname =
  match Db_wrapper.open_database dbname with
  | Some x -> process_file_with_db x
  | None -> print_endline "ERROR OPENING DATABASE!"

let command =
  Command.basic
    ~summary: "Generate capital gains report for stock sales."
    ~readme: (fun () -> "Generates details of stock sales and capital gain reports.")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map dbname = anon ("dbname" %: string) in
     fun () -> process_file dbname)

let () =
  Command_unix.run ~version:"0.1" command
