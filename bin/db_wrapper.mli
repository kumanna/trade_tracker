type t

val open_database : string -> t option

val close_database : t -> bool

val run_query : t -> string -> bool
