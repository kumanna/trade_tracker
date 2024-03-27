Trade Tracker
=============

A barebones trade tracker to track costs incurred when executing
delivery trades on Indian stock exchanges. Trades are stored in an
[Sqlite](https://sqlite.org) database that is used to generate reports
for tax filing purposes in India.

# Disclaimer
This software has absolutely no warranty and I cannot vouch for its
correctness. Use at your own risk.

# Usage
The program needs CSV inputs that contain the following headers:

    settlement_date,order_num,trade_num,trade_time,scrip,isin,buy_or_sell,quantity,peramount,exchange_fees,stt,stamp_duty,sebi_turnover_fees,brokerage,gst

The headers should be self explanatory. See
[example.csv.txt](example.csv.txt) and
[example2.csv.txt](example2.csv.txt) for examples. This format has to
be obtained from the broker's trade statement. If this is not
available as CSV, you need to get it from their PDF input using a tool
like [Tabula](https://tabula.technology/),
[Camelot](https://camelot-py.readthedocs.io/en/master/),
[pdftotext](https://pypi.org/project/pdftotext/) or other means.

You can import the transactions using:

    main.exe example.db example.csv.txt

If the brokerage and GST columns are missing, you can run the
`populate_brokerage` program to fill these in. For example, if the
brokerage is the minimum of 0.1% of the trade value or ₹ 20, and the
GST is 18%, use the following:

    populate_brokerage.exe example.db 0.1 20 18

Next, consolidate the holdings to enable statement generation:

    update_holdings.exe example.db

Finally, you can obtain reports like the following for the examples
provided. All the commands are provided for reference:

    ./main.exe example.db example.csv.txt
    ./main.exe example.db example2.csv.txt
    ./update_holdings.exe example.db
    ./capgain_report.exe example.db
    ./capgain_report.exe example.db 2023

The last pair of commands yield the following output:

    STCG REPORT
    Scrip: STOCKA
    Buy date: 2022-04-05
    Sell date: 2023-04-01
    Total value: 195.0
    Gain: 63.6
    Charges: 10.6864

    LTCG REPORT
    Scrip: STOCKA
    Buy date: 2022-04-05
    Sell date: 2023-08-08
    Total value: 76.96
    Gain: 27.6
    Charges: 5.8276

    STCG REPORT for 2023-2024
    Q1 total value of consideration: 110.04
    Q1 gain: 36.0
    Q1 charges: 5.2604
    Q1 net: 30.739600

    Q2: No transactions

    Q3: No transactions

    Q4 total value of consideration: 84.96
    Q4 gain: 27.6
    Q4 charges: 5.426
    Q4 net: 22.174000

    Q5: No transactions

    LTCG REPORT for 2023-2024
    Q1: No transactions

    Q2 total value of consideration: 76.96
    Q2 gain: 27.6
    Q2 charges: 5.8276
    Q2 net: 21.772400

    Q3: No transactions

    Q4: No transactions

    Q5: No transactions

In the above, `Q1`, `Q2` correspond to the deadlines for advance tax
as specified by the government. You can see the dates in the SQL
queries in [capgain_report.ml](./bin/capgain_report.ml).

# License
`trade_tracker` is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version. See
[LICENSE.txt](./LICENSE.txt) for details.
