open Core

let process_file f =
  let file = In_channel.create f in
  In_channel.input_lines file
  |> List.map ~f:(String.split ~on:',')
  |> List.map ~f:List.length
  |> List.iter ~f:(fun x -> print_endline (Int.to_string x))

let command =
  Command.basic
    ~summary: "Generate and maintain a database to track trades."
    ~readme: (fun () -> "More information (TODO)")
    (let open Command.Let_syntax in
     let open Command.Param in
     let%map filename = anon ("filename" %: string) in
     fun () -> process_file filename)

let () = Command_unix.run ~version:"0.1" command
