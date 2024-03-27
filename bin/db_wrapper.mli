(* Copyright 2024 Kumar Appaiah *)

(* This file is part of trade_tracker. *)

(* Foobar is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. *)

(* Foobar is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. *)

(* You should have received a copy of the GNU General Public License along with Foobar. If not, see <https://www.gnu.org/licenses/>.  *)

type t

val open_database : string -> t option

val close_database : t -> bool

val run_query : t -> string -> bool

val run_query_callback : t -> cb:(string option array -> unit) -> string -> bool
