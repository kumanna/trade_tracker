open Core

let print_stock_sale_info db sale_id buy_id n_stocks sale_price buy_price total_cost =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) ("select distinct scrip from raw_transaction_information where id = " ^ sale_id) then
    match !rows with
    | [[|Some scrip|]] ->
       let rows2 = ref [] in
       if Db_wrapper.run_query_callback db ~cb:(fun x -> rows2 := x::!rows2) (Printf.sprintf "select order_date from raw_transaction_information where id in (%s, %s) order by order_date;" sale_id buy_id) then
         match !rows2 with
         | [[|Some sell_date|]; [|Some buy_date|]] ->
            print_endline (Printf.sprintf "Stock sold: %s\nBuy date: %s\nSale date: %s\nValue of consideration: %.2f\nBuy price: %.2f\nGain: %.2f\nCosts incurred during transfer: %.2f\n" scrip buy_date sell_date (sale_price *. n_stocks) (buy_price *. n_stocks) ((sale_price -. buy_price) *. n_stocks) total_cost)
 | _ -> print_endline ("Error 1 generating sale report for sale id " ^ sale_id ^ "!")
       else
         print_endline ("Error 2 generating sale report for sale id " ^ sale_id ^ "!")
    | _ -> print_endline ("Error finding scrip for id " ^ sale_id ^ "!")
  else
    ()

let process_file_with_db db =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) "select sale_id, buy_id, n_stocks from sale_data join raw_transaction_information on raw_transaction_information.id = sale_data.sale_id order by raw_transaction_information.order_date, raw_transaction_information.order_num" then
    !rows
    |> List.rev
    |> List.iter ~f:(fun x ->
        match x with
        | [|Some sale_id; Some buy_id; Some n_stocks |] ->
           let rows2 = ref [] in
           if Db_wrapper.run_query_callback db ~cb:(fun x -> rows2 := x::!rows2) (Printf.sprintf "select peramount from raw_transaction_information where id in (%s, %s)" sale_id buy_id) then
             match !rows2 with
             | [[|Some buy_price|]; [|Some sale_price|]] ->
                (let rows3 = ref [] in
                 if Db_wrapper.run_query_callback db ~cb:(fun x -> rows3 := x::!rows3) (Printf.sprintf "select (exchange_fees + stamp_duty + sebi_turnover_fees + brokerage + gst) / quantity from raw_transaction_information where id in (%s, %s);" sale_id buy_id) then
                   let total_cost_per_stock =
                     match (List.rev !rows3) with
                     | [[|Some sell_cost|]; [|Some buy_cost|]] -> (Float.of_string sell_cost) +. (Float.of_string buy_cost)
                     | _ -> 0.0
                   in
                   let n_stocks = Float.of_string n_stocks in
                   let sale_price = Float.of_string sale_price in
                   let buy_price = Float.of_string buy_price in
                   print_stock_sale_info db sale_id buy_id n_stocks sale_price buy_price (total_cost_per_stock *. n_stocks)
                 else
                  print_endline ("Error 2 getting charges for sale and buy transactions " ^ sale_id ^ " and " ^ buy_id ^ "."))
             | _ -> print_endline ("Error 3 getting charges for sale and buy transactions " ^ sale_id ^ " and " ^ buy_id ^ ".")
           else
             print_endline ("Error matching sale and buy transactions " ^ sale_id ^ " and " ^ buy_id ^ ".")

        | _ -> print_endline "Error")
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
