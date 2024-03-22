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
  brokerage : float;
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
    brokerage =
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
      Float.to_string brokerage;
  ])

let list_to_transaction l =
  {
    settlement_date = List.nth_exn l 0;
    order = List.nth_exn l 1;
    trade_num = List.nth_exn l 2;
    trade_time = List.nth_exn l 3;
    scrip = List.nth_exn l 4;
    isin = List.nth_exn l 5;
    buy_or_sell = List.nth_exn l 6;
    quantity = List.nth_exn l 7 |> Float.of_string;
    peramount = List.nth_exn l 8 |> Float.of_string;
    exchange_fees = List.nth_exn l 9 |> Float.of_string;
    stt = List.nth_exn l 10 |> Float.of_string;
    stamp_duty = List.nth_exn l 11 |> Float.of_string;
    sebi_turnover_fees = List.nth_exn l 12 |> Float.of_string;
    brokerage = List.nth_exn l 13 |> Float.of_string;
  }

let get_order t
    = t.order
