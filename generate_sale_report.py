import sqlite3, sys
from datetime import date

RAW_TRANSACTION_DB_NAME = 'raw_transaction_information'
HOLDING_DB_NAME = 'current_holdings'
SALE_DB_NAME = 'sale_data'

class Stock_Sale:
    def __init__(self, scrip, buy_price, sell_price, buy_date, sell_date, charges):
        self.scrip = scrip
        self.buy_price = buy_price
        self.sell_price = sell_price
        self.stcg = True
        if (sell_date - buy_date).days > 365:
            self.stcg = False
        self.sell_date = sell_date
        self.charges = charges

    def get_stcg(self):
        if self.stcg:
            return ((self.sell_price - self.buy_price) - self.charges)
        return None

    def get_ltcg(self):
        if not self.stcg:
            return ((self.sell_price - self.buy_price) - self.charges)
        return None

db = sqlite3.connect(sys.argv[1])
cur = db.cursor()
cur.execute(f'''
select sale_id, buy_id, n_stocks from {SALE_DB_NAME}
join {RAW_TRANSACTION_DB_NAME} on {RAW_TRANSACTION_DB_NAME}.id = {SALE_DB_NAME}.sale_id
order by {RAW_TRANSACTION_DB_NAME}.order_date, {RAW_TRANSACTION_DB_NAME}.order_num
''')
stock_sales = []
for r in cur.fetchall():
    # Find the stock name
    sale_id = r[0]
    buy_id = r[1]
    n_stocks = r[2]
    cur.execute(f'''select scrip from {RAW_TRANSACTION_DB_NAME}
    where id in ({sale_id}, {buy_id})
    ''')
    scrip, scrip1 = (i[0] for i in cur.fetchall())
    assert scrip == scrip1
    # Find the buy and sale costs
    cur.execute(f'''select peramount from {RAW_TRANSACTION_DB_NAME}
    where id in ({sale_id}, {buy_id})
    ''')
    sale_price, buy_price = (i[0] for i in cur.fetchall())
    # Find the per-stock expenses during sale and buy
    cur.execute(f'''
    select (exchange_fees + stamp_duty + sebi_turnover_fees + brokerage + gst) / quantity
    from {RAW_TRANSACTION_DB_NAME}
    where id in ({sale_id}, {buy_id});
    ''')
    total_cost_per_stock = sum((i[0] for i in cur.fetchall()))
    cur.execute(f'''
    select order_date
    from {RAW_TRANSACTION_DB_NAME}
    where id in ({sale_id}, {buy_id}) order by order_date desc;
    ''')
    result = [i[0] for i in cur.fetchall()]
    sale_date, buy_date = result[0], result[1]
    sale_date = date(int(sale_date[:4]), int(sale_date[5:7]), int(sale_date[8:]))
    buy_date = date(int(buy_date[:4]), int(buy_date[5:7]), int(buy_date[8:]))
    holding_days = (sale_date - buy_date).days
    print(f"Stock sold: {scrip}")
    print(f"Buy date: {buy_date}")
    print(f"Sale date: {sale_date}")
    print(f"Value of consideration: {sale_price * n_stocks:.2f}")
    print(f"Buy price: {buy_price * n_stocks:.2f}")
    print(f"Gain: {(sale_price - buy_price) * n_stocks:.2f}")
    print(f"Costs incurred during transfer: {total_cost_per_stock * n_stocks:.2f}")
    print()
    stock_sales.append(Stock_Sale(scrip, buy_price * n_stocks, sale_price * n_stocks, buy_date, sale_date, total_cost_per_stock * n_stocks))
db.close()

def sum_capgains(stock_sales, fy_begin, stcg = True):
    begin_date = date(fy_begin, 4, 1)
    q1end = date(fy_begin, 6, 30)
    q2end = date(fy_begin, 9, 30)
    q3end = date(fy_begin, 12, 31)
    q4end = date(fy_begin + 1, 3, 15)
    q5end = date(fy_begin + 1, 3, 31)
    get_capgains = lambda x : x.get_stcg()
    if not stcg:
        get_capgains = lambda x : x.get_ltcg()
    q1_gain = sum(map(get_capgains, filter(get_capgains, (i for i in stock_sales if i.sell_date >= begin_date and i.sell_date <= q1end))))
    q2_gain = sum(map(get_capgains, filter(get_capgains, (i for i in stock_sales if i.sell_date > q1end and i.sell_date <= q2end))))
    q3_gain = sum(map(get_capgains, filter(get_capgains, (i for i in stock_sales if i.sell_date > q2end and i.sell_date <= q3end))))
    q4_gain = sum(map(get_capgains, filter(get_capgains, (i for i in stock_sales if i.sell_date > q3end and i.sell_date <= q4end))))
    q5_gain = sum(map(get_capgains, filter(get_capgains, (i for i in stock_sales if i.sell_date > q4end and i.sell_date <= q5end))))
    return q1_gain, q2_gain, q3_gain, q4_gain, q5_gain


if len(sys.argv) > 2:
    fy_begin = int(sys.argv[2])
    begin_date = date(fy_begin, 4, 1)
    end_date = date(fy_begin + 1, 3, 31)
    current_year_sales = [i for i in stock_sales if i.sell_date >= begin_date and i.sell_date <= end_date]
    print("STCG summary:")
    q1_ltcg, q2_ltcg, q3_ltcg, q4_ltcg, q5_ltcg = sum_capgains(current_year_sales, fy_begin)
    print(f"{fy_begin}-04-01 to {fy_begin}-06-30: {q1_ltcg:,.2f}")
    print(f"{fy_begin}-01-07 to {fy_begin}-09-30: {q2_ltcg:,.2f}")
    print(f"{fy_begin}-10-01 to {fy_begin}-12-31: {q3_ltcg:,.2f}")
    print(f"{fy_begin+1}-01-01 to {fy_begin+1}-03-15: {q4_ltcg:,.2f}")
    print(f"{fy_begin+1}-03-16 to {fy_begin+1}-03-31: {q5_ltcg:,.2f}")
    print()
    print("LTCG summary:")
    q1_ltcg, q2_ltcg, q3_ltcg, q4_ltcg, q5_ltcg = sum_capgains(current_year_sales, fy_begin, False)
    print(f"{fy_begin}-04-01 to {fy_begin}-06-30: {q1_ltcg:,.2f}")
    print(f"{fy_begin}-01-07 to {fy_begin}-09-30: {q2_ltcg:,.2f}")
    print(f"{fy_begin}-10-01 to {fy_begin}-12-31: {q3_ltcg:,.2f}")
    print(f"{fy_begin+1}-01-01 to {fy_begin+1}-03-15: {q4_ltcg:,.2f}")
    print(f"{fy_begin+1}-03-16 to {fy_begin+1}-03-31: {q5_ltcg:,.2f}")
    print()
