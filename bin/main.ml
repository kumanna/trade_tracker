open Core
open Transaction

let process_file dbname f =
  let db = Sqlite3.db_open dbname in
  let file = In_channel.create f in
  In_channel.input_lines file
  |> List.tl_exn
  |> List.map ~f:(String.split ~on:',')
  |> List.map ~f:list_to_transaction
  |> List.iter ~f:print_transaction;
  if Sqlite3.db_close db then print_endline "Success!" else print_endline "Failure!"

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
