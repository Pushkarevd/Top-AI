-- ============================================================================
-- Скрипт создания OLAP-схемы (хранилище данных)
-- ============================================================================

-- Переключиться на базу данных ecommerce_olap
-- \c ecommerce_olap;

-- ============================================================================
-- 1. СОЗДАНИЕ ТАБЛИЦ ИЗМЕРЕНИЙ
-- ============================================================================

-- Измерение: Время
CREATE TABLE IF NOT EXISTS dim_date (
    date_id INTEGER PRIMARY KEY,
    full_date DATE NOT NULL,
    day INTEGER NOT NULL,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    is_holiday BOOLEAN DEFAULT FALSE
);

-- Измерение: Пользователь
CREATE TABLE IF NOT EXISTS dim_user (
    user_key SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    username VARCHAR(50),
    email VARCHAR(100),
    registration_date DATE,
    city VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индекс для быстрого поиска по user_id
CREATE INDEX IF NOT EXISTS idx_dim_user_id ON dim_user(user_id);

-- Измерение: Товар
CREATE TABLE IF NOT EXISTS dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(200),
    category_id INTEGER,
    category_name VARCHAR(100),
    parent_category_name VARCHAR(100),
    current_price NUMERIC(10, 2),
    current_cost NUMERIC(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для измерения товаров
CREATE INDEX IF NOT EXISTS idx_dim_product_id ON dim_product(product_id);
CREATE INDEX IF NOT EXISTS idx_dim_product_category ON dim_product(category_id);

-- Измерение: Статус заказа
CREATE TABLE IF NOT EXISTS dim_order_status (
    status_key SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_status VARCHAR(20),
    order_date TIMESTAMP,
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индекс для поиска по order_id
CREATE INDEX IF NOT EXISTS idx_dim_order_status_id ON dim_order_status(order_id);

-- ============================================================================
-- 2. СОЗДАНИЕ ТАБЛИЦЫ ФАКТОВ
-- ============================================================================

CREATE TABLE IF NOT EXISTS fact_sales (
    sale_id BIGSERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    date_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    discount_percent NUMERIC(5, 2) NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL,
    cost NUMERIC(10, 2) NOT NULL,
    profit NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Индексы для таблицы фактов
CREATE INDEX IF NOT EXISTS idx_fact_sales_user ON fact_sales(user_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_date ON fact_sales(date_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_category ON fact_sales(category_id);
CREATE INDEX IF NOT EXISTS idx_fact_sales_order ON fact_sales(order_id);

-- Комбинированный индекс для частых запросов
CREATE INDEX IF NOT EXISTS idx_fact_sales_date_category 
ON fact_sales(date_id, category_id);

-- ============================================================================
-- 3. ПРОСМОТР СОЗДАННЫХ ТАБЛИЦ
-- ============================================================================

\dt

-- Просмотр структуры
\d dim_date
\d dim_user
\d dim_product
\d fact_sales
