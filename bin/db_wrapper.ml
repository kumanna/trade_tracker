
type t = Sqlite3.db

let create_db_query = "CREATE TABLE IF NOT EXISTS raw_transaction_information \
    (id INTEGER PRIMARY KEY AUTOINCREMENT, \
    order_date TEXT NOT NULL, \
    order_num TEXT NOT NULL, \
    trade_num TEXT NOT NULL, \
    trade_time TEXT NOT NULL, \
    scrip TEXT NOT NULL, \
    isin TEXT NOT NULL, \
    buy_or_sell TEXT NOT NULL, \
    quantity REAL NOT NULL, \
    peramount REAL NOT NULL, \
    exchange_fees REAL NOT NULL, \
    stt REAL NOT NULL, \
    stamp_duty REAL NOT NULL, \
    sebi_turnover_fees REAL NOT NULL, \
    brokerage REAL, \
    gst REAL, \
    UNIQUE(order_date, order_num, scrip, trade_num) \
    );"

let open_database filename =
  let query = create_db_query in
  let db = Sqlite3.db_open filename in
  match Sqlite3.exec db query with
  | Sqlite3.Rc.OK -> Some db
  | _ -> None


let close_database db =
  Sqlite3.db_close db

let run_query db query =
  match Sqlite3.exec db query with
  | Sqlite3.Rc.OK -> true
  | _ -> false
