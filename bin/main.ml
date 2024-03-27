(* Copyright 2024 Kumar Appaiah *)

(* This file is part of trade_tracker. *)

(* Foobar is free software: you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version. *)

(* Foobar is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details. *)

(* You should have received a copy of the GNU General Public License
   along with Foobar. If not, see <https://www.gnu.org/licenses/>.  *)

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
