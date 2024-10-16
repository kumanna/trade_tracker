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
   along with Foobar. If not, see <https://www.gnu.org/licenses/>. *)

type t = Sqlite3.db

let create_db_query =
  "CREATE TABLE IF NOT EXISTS raw_transaction_information (id INTEGER PRIMARY \
   KEY AUTOINCREMENT, order_date TEXT NOT NULL, order_num TEXT NOT NULL, \
   trade_num TEXT NOT NULL, trade_time TEXT NOT NULL, scrip TEXT NOT NULL, \
   isin TEXT NOT NULL, buy_or_sell TEXT NOT NULL, quantity REAL NOT NULL, \
   peramount REAL NOT NULL, exchange_fees REAL NOT NULL, stt REAL NOT NULL, \
   stamp_duty REAL NOT NULL, sebi_turnover_fees REAL NOT NULL, brokerage REAL, \
   gst REAL, UNIQUE(order_date, order_num, scrip, trade_num) );"

let open_database ?(readonly = false) filename =
  let query = create_db_query in
  let db =
    if readonly then Sqlite3.(db_open ~mode:`READONLY filename)
    else Sqlite3.db_open filename
  in
  match Sqlite3.exec db query with Sqlite3.Rc.OK -> Some db | _ -> None

let close_database db = Sqlite3.db_close db

let run_query db query =
  match Sqlite3.exec db query with Sqlite3.Rc.OK -> true | _ -> false

let run_query_callback db ~cb query =
  match Sqlite3.exec_no_headers db ~cb query with
  | Sqlite3.Rc.OK -> true
  | _ -> false
