open Core

let list_filename f =
  print_endline f

let command =
  Command.basic
    ~summary: "Generate and maintain a database to track trades."
    ~readme: (fun () -> "More information (TODO)")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map filename = anon ("filename" %: string) in
     fun () -> list_filename filename)

let () = Command_unix.run ~version:"0.1" command
