open Core

let rec handle_sell db sale_id n_quantity_to_sell =
  if Float.(n_quantity_to_sell < 0.000001) then
    ()
  else
    let rows = ref [] in
    if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) ("select isin from raw_transaction_information where id = " ^ sale_id ^ " limit 1;") then
      let isin = (List.hd_exn !rows).(0) |> Option.value ~default:"" in
      let buyrows = ref [] in
      if Db_wrapper.run_query_callback db ~cb:(fun x -> buyrows := x::!buyrows) ("select lot_id, n_stocks from current_holdings join raw_transaction_information on raw_transaction_information.id = lot_id where isin = '" ^ isin ^ "';")
      then
        match List.hd_exn !buyrows with
        | [|Some buy_id;Some quantity|] ->
           let quantity = Float.of_string quantity in
           if Float.(quantity > n_quantity_to_sell) then
             if Db_wrapper.run_query db (Printf.sprintf "insert into sale_data (sale_id, buy_id, n_stocks) values (%s, %s, %f)" sale_id buy_id n_quantity_to_sell) && (Db_wrapper.run_query db (Printf.sprintf "update current_holdings set n_stocks = %f where lot_id = %s;" (quantity -. n_quantity_to_sell) buy_id)) then
               print_endline ("Imported sale transaction for " ^ sale_id ^ "!")
             else
               print_endline ("Error importing sale transaction for " ^ sale_id ^ "!")
           else
               if Db_wrapper.run_query db (Printf.sprintf "insert into sale_data (sale_id, buy_id, n_stocks) values (%s, %s, %f)" sale_id buy_id quantity) && Db_wrapper.run_query db ("delete from current_holdings where lot_id = " ^ buy_id ^ ";") then
                 handle_sell db sale_id (n_quantity_to_sell -. quantity)
        | _ -> print_endline ("Failure in sale transaction " ^ sale_id ^ "!")
      else
        print_endline ("Error handling sale with id " ^ sale_id ^ "!")

let handle_buy db id quantity =
  if (Db_wrapper.run_query db ("insert into current_holdings (lot_id, n_stocks) values (" ^ id ^ "," ^ quantity ^ ");")) then
    ()
  else
    print_endline ("Error adding holding " ^ id ^ "!")

let handle_buy_and_sell db entry =
  match entry with
  | [|Some id;Some quantity;Some buy_or_sell|] ->
     if (String.equal buy_or_sell "B") then handle_buy db id quantity else handle_sell db id (Float.of_string quantity)
  | _ -> print_endline "ERROR GENERATING HOLDINGS!"

let get_pending_holdings db =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) "select id, quantity, buy_or_sell from raw_transaction_information where id not in (select distinct lot_id from current_holdings union select sale_id from sale_data) order by (order_date || id) desc" then
    List.iter ~f:(handle_buy_and_sell db) !rows
  else
    print_endline "ERROR"


let process_with_db db =
  if Db_wrapper.run_query db "CREATE TABLE IF NOT EXISTS current_holdings (lot_id INTEGER NOT NULL, n_stocks REAL NOT NULL);" then
    print_endline "Holdings table exists!"
  else
    print_endline "Error creating holdings table!";
  if Db_wrapper.run_query db "CREATE TABLE IF NOT EXISTS sale_data (sale_id INTEGER NOT NULL, buy_id INTEGER NOT NULL, n_stocks REAL NOT NULL);" then
    print_endline "Sale data table exists!"
  else
    print_endline "Error creating sale data table!";
  get_pending_holdings db;
  (* Find the holdings for which we do not have the lots yet. *)
  if Db_wrapper.close_database db then print_endline "Holdings generated!" else print_endline "Failure during holdings generation!"

let process_file dbname =
  match Db_wrapper.open_database dbname with
  | Some x -> process_with_db x
  | None -> print_endline "ERROR OPENING DATABASE!"

let command =
  Command.basic
    ~summary: "Generate holdings and sale information."
    ~readme: (fun () -> "Refreshes the holdings and sale information.")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map dbname = anon ("dbname" %: string) in
     fun () -> process_file dbname)

let () =
  Command_unix.run ~version:"0.1" command
