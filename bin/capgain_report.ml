open Core

let query_stcg = "select S.scrip, B.order_date, S.order_date,sum(n_stocks * S.peramount) as total_value, sum(n_stocks * (S.peramount - B.peramount)) as gain, sum(n_stocks * (B.exchange_fees + B.stamp_duty + B.sebi_turnover_fees + B.brokerage + B.gst) / B.quantity + n_stocks * (S.exchange_fees + S.stamp_duty + S.sebi_turnover_fees + S.brokerage + S.gst) / S.quantity) as total_charges from sale_data join raw_transaction_information as S on S.id = sale_id join raw_transaction_information as B on B.id = buy_id where julianday(S.order_date) - julianday(B.order_date) < 365 group by S.scrip"

let query_ltcg = "select S.scrip, B.order_date, S.order_date,sum(n_stocks * S.peramount) as total_value, sum(n_stocks * (S.peramount - B.peramount)) as gain, sum(n_stocks * (B.exchange_fees + B.stamp_duty + B.sebi_turnover_fees + B.brokerage + B.gst) / B.quantity + n_stocks * (S.exchange_fees + S.stamp_duty + S.sebi_turnover_fees + S.brokerage + S.gst) / S.quantity) as total_charges from sale_data join raw_transaction_information as S on S.id = sale_id join raw_transaction_information as B on B.id = buy_id where julianday(S.order_date) - julianday(B.order_date) >= 365 group by S.scrip"

let process_file_with_db db query =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) query then
    List.rev !rows
    |> List.iter ~f:(fun x ->
           match x with
           | [|Some scrip;Some buy_date;Some sell_date;Some total_value;Some gain;Some total_charges |] ->
              print_endline (Printf.sprintf "Scrip: %s\nBuy date: %s\nSell date: %s\nTotal value: %s\nGain: %s\nCharges: %s\n" scrip buy_date sell_date total_value gain  total_charges)
           | _ -> print_endline "Error getting STCG details!")

let process_file dbname =
  match Db_wrapper.open_database dbname with
  | Some x -> (print_endline "STCG REPORT";
               process_file_with_db x query_stcg;
               print_endline "LTCG REPORT";
               process_file_with_db x query_ltcg;
               if Db_wrapper.close_database x then
                 ()
               else print_endline "Failure closing database!")
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
