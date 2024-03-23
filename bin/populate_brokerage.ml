open Core

let update_brokerage_gst db order_num brokerage =
  Db_wrapper.run_query db
    (Printf.sprintf "update raw_transaction_information set brokerage = %f * quantity where order_num = '%s';" brokerage order_num)
  && Db_wrapper.run_query db
       (Printf.sprintf "update raw_transaction_information set gst = 0.18 * (sebi_turnover_fees + brokerage + exchange_fees) where order_num = '%s';" order_num)

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

let process_file_with_db db percentage flatfee =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) "select distinct order_num from raw_transaction_information where brokerage is NULL;"
  then
    List.map ~f:(fun x -> (match x.(0) with
                           | Some a -> (let (amount, quantity) = get_order_total_amounts db a in
                                        let b = if (Float.(amount *. percentage /. 100. > flatfee)) then flatfee /. quantity else amount *. percentage /. quantity /. 100. in
                                        if update_brokerage_gst db a b then
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

let add_missing_brokerages dbname percentage flatfee =
  match Db_wrapper.open_database dbname with
  | Some x -> process_file_with_db x percentage flatfee
  | None -> print_endline "ERROR OPENING DATABASE!"

let command =
  Command.basic
    ~summary: "Populate brokerage and GST."
    ~readme: (fun () -> "Populates brokerage and GST based on minimum of a flat fee and percentage")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map dbname = anon ("dbname" %: string) and
        percentage = anon ("percentage" %: float) and
        flatfee = anon ("flatfee" %: float)
     in
     fun () -> add_missing_brokerages dbname percentage flatfee)

let () =
  Command_unix.run ~version:"0.1" command
