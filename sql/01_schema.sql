CREATE TABLE stage_customers (
    customer_id TEXT PRIMARY KEY, customer_name TEXT NOT NULL, email TEXT,
    region TEXT NOT NULL, joined_date TEXT NOT NULL
);
CREATE TABLE stage_products (
    product_id TEXT PRIMARY KEY, product_name TEXT NOT NULL,
    category TEXT NOT NULL, standard_cost NUMERIC NOT NULL
);
CREATE TABLE stage_transactions (
    line_id TEXT PRIMARY KEY, order_id TEXT NOT NULL, order_date TEXT NOT NULL,
    customer_id TEXT NOT NULL, product_id TEXT NOT NULL, quantity INTEGER NOT NULL,
    unit_price NUMERIC NOT NULL, returned_quantity INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE dim_date (
    date_key INTEGER PRIMARY KEY, full_date TEXT UNIQUE NOT NULL, day_of_month INTEGER,
    month_name TEXT, month_number INTEGER, quarter_number INTEGER, year_number INTEGER,
    day_name TEXT, is_weekend INTEGER
);
CREATE TABLE dim_customer (
    customer_key INTEGER PRIMARY KEY AUTOINCREMENT, customer_id TEXT UNIQUE NOT NULL,
    customer_name TEXT NOT NULL, email TEXT, region TEXT NOT NULL, joined_date TEXT NOT NULL
);
CREATE TABLE dim_product (
    product_key INTEGER PRIMARY KEY AUTOINCREMENT, product_id TEXT UNIQUE NOT NULL,
    product_name TEXT NOT NULL, category TEXT NOT NULL, standard_cost NUMERIC NOT NULL
);
CREATE TABLE fact_sales (
    sales_key INTEGER PRIMARY KEY AUTOINCREMENT, line_id TEXT UNIQUE NOT NULL,
    order_id TEXT NOT NULL, date_key INTEGER NOT NULL, customer_key INTEGER NOT NULL,
    product_key INTEGER NOT NULL, quantity INTEGER NOT NULL, unit_price NUMERIC NOT NULL,
    returned_quantity INTEGER NOT NULL, gross_revenue NUMERIC NOT NULL,
    return_value NUMERIC NOT NULL, net_revenue NUMERIC NOT NULL,
    FOREIGN KEY(date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY(customer_key) REFERENCES dim_customer(customer_key),
    FOREIGN KEY(product_key) REFERENCES dim_product(product_key),
    CHECK(quantity > 0), CHECK(returned_quantity BETWEEN 0 AND quantity)
);

CREATE INDEX idx_sales_date ON fact_sales(date_key);
CREATE INDEX idx_sales_customer ON fact_sales(customer_key);
CREATE INDEX idx_sales_product ON fact_sales(product_key);

