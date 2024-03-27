(* Copyright 2024 Kumar Appaiah *)

(* This file is part of trade_tracker. *)

(* Foobar is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. *)

(* Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. *)

(* You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.  *)

type t

type transaction_type

val create_transaction :
  string -> (* settlement_date *)
  string -> (* order *)
  string -> (* trade_num *)
  string -> (* trade_time *)
  string -> (* scrip *)
  string -> (* isin *)
  transaction_type -> (* buy_or_sell *)
  float -> (* quantity *)
  float -> (* peramount *)
  float -> (* exchange_fees *)
  float -> (* stt *)
  float -> (* stamp_duty *)
  float -> (* sebi_turnover_fees *)
  float option -> (* brokerage *)
  float option -> (* gst *)
  t

val list_to_transaction : string list -> t option

val get_order : t -> string

val print_transaction : t -> unit

val db_insert_transaction : Db_wrapper.t -> t -> bool
