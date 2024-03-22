type t

val create_transaction :
  string -> (* settlement_date *)
  string -> (* order *)
  string -> (* trade_num *)
  string -> (* trade_time *)
  string -> (* scrip *)
  string -> (* isin *)
  string -> (* buy_or_sell *)
  float -> (* quantity *)
  float -> (* peramount *)
  float -> (* exchange_fees *)
  float -> (* stt *)
  float -> (* stamp_duty *)
  float -> (* sebi_turnover_fees *)
  float option -> (* brokerage *)
  float option -> (* gst *)
  t

val list_to_transaction : string list -> t

val get_order : t -> string

val print_transaction : t -> unit
