open Core
open Transaction

let process_file_with_db db f =
  let file = In_channel.create f in
  if (In_channel.input_lines file
  |> List.tl_exn
  |> List.map ~f:(String.split ~on:',')
  |> List.filter_map ~f:list_to_transaction
  |> List.map ~f:(db_insert_transaction db)
  |> List.fold_right ~f:(fun x y -> x && y) ~init:true)
  then
    if Db_wrapper.close_database db then print_endline "Success!" else print_endline "Failure!"
  else
    print_endline "FAILURE DURING INSERT: have you already imported these transactions?"

let process_file dbname f =
  match Db_wrapper.open_database dbname with
  | Some x -> process_file_with_db x f
  | None -> print_endline "ERROR OPENING DATABASE!"

let command =
  Command.basic
    ~summary: "Generate and maintain a database to track trades."
    ~readme: (fun () -> "More information (TODO)")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map dbname = anon ("dbname" %: string) and
       filename = anon ("filename" %: string) in
     fun () -> process_file dbname filename)

let () =
  Command_unix.run ~version:"0.1" command
