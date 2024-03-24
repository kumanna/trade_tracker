open Core

type transaction_type =
  | Buy
  | Sell

type t = {
  settlement_date : string;
  order : string;
  trade_num : string;
  trade_time : string;
  scrip : string;
  isin : string;
  buy_or_sell : transaction_type;
  quantity : float;
  peramount : float;
  exchange_fees : float;
  stt : float;
  stamp_duty : float;
  sebi_turnover_fees : float;
  brokerage : float option;
  gst : float option;
}

let create_transaction
    settlement_date
    order
    trade_num
    trade_time
    scrip
    isin
    buy_or_sell
    quantity
    peramount
    exchange_fees
    stt
    stamp_duty
    sebi_turnover_fees
    brokerage
    gst =
  {
    settlement_date;
    order;
    trade_num;
    trade_time;
    scrip;
    isin;
    buy_or_sell;
    quantity;
    peramount;
    exchange_fees;
    stt;
    stamp_duty;
    sebi_turnover_fees;
    brokerage;
    gst;
  }

let print_transaction   {
    settlement_date;
    order;
    trade_num;
    trade_time;
    scrip;
    isin;
    buy_or_sell;
    quantity;
    peramount;
    exchange_fees;
    stt;
    stamp_duty;
    sebi_turnover_fees;
    brokerage;
    gst;
  } =
  print_endline (String.concat ~sep:"," [
      settlement_date;
      order;
      trade_num;
      trade_time;
      scrip;
      isin;
      (match buy_or_sell with
      | Buy -> "B"
      | Sell -> "S");
      Float.to_string quantity;
      Float.to_string peramount;
      Float.to_string exchange_fees;
      Float.to_string stt;
      Float.to_string stamp_duty;
      Float.to_string sebi_turnover_fees;
      (match brokerage with
      | None -> "NOBROKERAGE"
      | Some x -> Float.to_string x);
      (match gst with
      | None -> "NOGST"
      | Some x -> Float.to_string x);
  ])

let list_to_transaction l =
  let r =   {
      settlement_date = List.nth_exn l 0;
      order = List.nth_exn l 1;
      trade_num = List.nth_exn l 2;
      trade_time = List.nth_exn l 3;
      scrip = List.nth_exn l 4;
      isin = List.nth_exn l 5;
      buy_or_sell = Buy;
      quantity = List.nth_exn l 7 |> Float.of_string;
      peramount = List.nth_exn l 8 |> Float.of_string;
      exchange_fees = List.nth_exn l 9 |> Float.of_string;
      stt = (let x = (List.nth_exn l 10) in
             if String.length x > 0 then
               Float.of_string x
             else
               0.0);
      stamp_duty = (let x = (List.nth_exn l 10) in
             if String.length x > 0 then
               Float.of_string x
             else
               0.0);
      sebi_turnover_fees = List.nth_exn l 12 |> Float.of_string;
      brokerage = (let v = List.nth_exn l 13 in
                   if String.length v > 0 then Some (Float.of_string v) else None);
      gst = (let v = List.nth_exn l 14 in
             if String.length v > 0 then Some (Float.of_string v) else None);
    }
  in
  match (List.nth_exn l 6) with
  | "buy" | "BUY" | "b" | "B" -> Some { r with buy_or_sell = Buy }
  | "sell" | "SELL" | "s" | "S" -> Some { r with buy_or_sell = Sell }
  | _ -> None

let get_order t
    = t.order

let db_insert_transaction db t =
  let query = Printf.sprintf "insert into raw_transaction_information \
    (order_date, \
    order_num, \
    trade_num, \
    trade_time, \
    scrip, \
    isin, \
    buy_or_sell, \
    quantity, \
    peramount, \
    exchange_fees, \
    stt, \
    stamp_duty, \
    sebi_turnover_fees, \
    brokerage, \
    gst) \
    values ( \
    \"%s\", \
    \"%s\", \
    \"%s\", \
    \"%s\", \
    \"%s\", \
    \"%s\", \
    \"%s\", \
    %f, \
    %f, \
    %f, \
    %f, \
    %f, \
    %f, \
    %s, \
    %s);"
      t.settlement_date
      t.order
      t.trade_num
      t.trade_time
      t.scrip
      t.isin
      (match t.buy_or_sell with
       | Sell -> "S"
       | Buy -> "B")
      t.quantity
      t.peramount
      t.exchange_fees
      t.stt
      t.stamp_duty
      t.sebi_turnover_fees
      (match t.brokerage with
      | None -> "NULL"
      | Some x -> Float.to_string x)
      (match t.gst with
      | None -> "NULL"
      | Some x -> Float.to_string x)
  in
  Db_wrapper.run_query db query
