open Core

type t = {
  settlement_date : string;
  order : string;
  trade_num : string;
  trade_time : string;
  scrip : string;
  isin : string;
  buy_or_sell : string;
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
      buy_or_sell;
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
  {
    settlement_date = List.nth_exn l 0;
    order = List.nth_exn l 1;
    trade_num = List.nth_exn l 2;
    trade_time = List.nth_exn l 3;
    scrip = List.nth_exn l 4;
    isin = List.nth_exn l 5;
    buy_or_sell = (match (List.nth_exn l 6) with
      | "buy" | "BUY" | "b" | "B" -> "B"
      | "sell" | "SELL" | "s" | "S" -> "S"
      | _ -> "");
    quantity = List.nth_exn l 7 |> Float.of_string;
    peramount = List.nth_exn l 8 |> Float.of_string;
    exchange_fees = List.nth_exn l 9 |> Float.of_string;
    stt = List.nth_exn l 10 |> Float.of_string;
    stamp_duty = List.nth_exn l 11 |> Float.of_string;
    sebi_turnover_fees = List.nth_exn l 12 |> Float.of_string;
    brokerage = (let v = List.nth_exn l 13 in
      if String.length v > 0 then Some (Float.of_string v) else None);
    gst = (let v = List.nth_exn l 14 in
      if String.length v > 0 then Some (Float.of_string v) else None);
  }

let get_order t
    = t.order
