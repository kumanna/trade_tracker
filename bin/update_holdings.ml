open Core

let handle_buy_and_sell entry =
  match entry with
  | [|Some id;Some quantity;Some buy_or_sell|] -> print_endline (id ^ "," ^ quantity ^ "," ^ buy_or_sell)
  | _ -> print_endline "ERROR GENERATING HOLDINGS!"

let get_pending_holdings db =
  let rows = ref [] in
  if Db_wrapper.run_query_callback db ~cb:(fun x -> rows := x::!rows) "select id, quantity, buy_or_sell from raw_transaction_information where id not in (select distinct lot_id from current_holdings union select sale_id from sale_data) order by order_date, id desc" then
    List.iter ~f:(fun x -> handle_buy_and_sell x) !rows
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
