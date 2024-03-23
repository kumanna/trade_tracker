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
