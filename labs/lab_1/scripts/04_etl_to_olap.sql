-- ============================================================================
-- Скрипт заполнения хранилища данных (ETL-процесс)
-- ============================================================================

-- Переключиться на базу данных ecommerce_olap
-- \c ecommerce_olap;

-- ============================================================================
-- 1. ЗАПОЛНЕНИЕ ИЗМЕРЕНИЯ ВРЕМЕНИ
-- ============================================================================

INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week, day_name, month_name, is_weekend, is_holiday)
SELECT 
    TO_CHAR(d, 'YYYYMMDD')::integer AS date_id,
    d AS full_date,
    EXTRACT(DAY FROM d)::integer AS day,
    EXTRACT(MONTH FROM d)::integer AS month,
    EXTRACT(YEAR FROM d)::integer AS year,
    EXTRACT(QUARTER FROM d)::integer AS quarter,
    EXTRACT(DOW FROM d)::integer AS day_of_week,
    TO_CHAR(d, 'Day') AS day_name,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(DOW FROM d) IN (0, 6) AS is_weekend,
    FALSE AS is_holiday
FROM generate_series(
    CURRENT_DATE - 365,
    CURRENT_DATE + 30,
    '1 day'::interval
) AS d;

-- Проверка
SELECT 
    year,
    month,
    COUNT(*) AS days_count,
    SUM(CASE WHEN is_weekend THEN 1 ELSE 0 END) AS weekend_days
FROM dim_date
GROUP BY year, month
ORDER BY year, month;

-- ============================================================================
-- 2. ЗАПОЛНЕНИЕ ИЗМЕРЕНИЯ ПОЛЬЗОВАТЕЛЕЙ
-- ============================================================================

-- Подключение к OLTP базе для получения данных
-- Альтернативно можно использовать dblink или предварительно экспортировать данные

INSERT INTO dim_user (user_id, username, email, registration_date)
SELECT 
    user_id,
    username,
    email,
    created_at::date
FROM ecommerce_oltp.public.users
ON CONFLICT (user_id) DO NOTHING;

-- Проверка
SELECT COUNT(*) AS users_count FROM dim_user;

-- ============================================================================
-- 3. ЗАПОЛНЕНИЕ ИЗМЕРЕНИЯ ТОВАРОВ
-- ============================================================================

INSERT INTO dim_product (product_id, product_name, category_id, category_name, current_price, current_cost)
SELECT 
    p.product_id,
    p.product_name,
    c.category_id,
    c.category_name,
    p.price,
    p.cost
FROM ecommerce_oltp.public.products p
JOIN ecommerce_oltp.public.categories c ON p.category_id = c.category_id
ON CONFLICT (product_id) DO NOTHING;

-- Обновление названий родительских категорий
UPDATE dim_product dp
SET parent_category_name = pc.category_name
FROM ecommerce_oltp.public.categories c
JOIN ecommerce_oltp.public.categories pc ON c.parent_category_id = pc.category_id
WHERE dp.category_id = c.category_id
  AND dp.parent_category_name IS NULL;

-- Проверка
SELECT 
    category_name,
    COUNT(*) AS products_count,
    ROUND(AVG(current_price), 2) AS avg_price,
    ROUND(AVG(current_cost), 2) AS avg_cost
FROM dim_product
GROUP BY category_id, category_name
ORDER BY products_count DESC;

-- ============================================================================
-- 4. ЗАПОЛНЕНИЕ ИЗМЕРЕНИЯ СТАТУСОВ ЗАКАЗОВ
-- ============================================================================

INSERT INTO dim_order_status (order_id, order_status, order_date, shipped_date, delivered_date)
SELECT 
    order_id,
    order_status,
    order_date,
    shipped_date,
    delivered_date
FROM ecommerce_oltp.public.orders
ON CONFLICT (order_id) DO NOTHING;

-- Проверка
SELECT 
    order_status,
    COUNT(*) AS orders_count
FROM dim_order_status
GROUP BY order_status
ORDER BY orders_count DESC;

-- ============================================================================
-- 5. ЗАПОЛНЕНИЕ ТАБЛИЦЫ ФАКТОВ
-- ============================================================================

-- Основной ETL-запрос для загрузки фактов продаж
INSERT INTO fact_sales (order_id, user_id, product_id, category_id, date_id, quantity, unit_price, discount_percent, total_amount, cost, profit)
SELECT 
    oi.order_id,
    o.user_id,
    oi.product_id,
    p.category_id,
    TO_CHAR(o.order_date, 'YYYYMMDD')::integer AS date_id,
    oi.quantity,
    oi.unit_price,
    oi.discount,
    (oi.unit_price * oi.quantity * (1 - oi.discount / 100)) AS total_amount,
    (p.cost * oi.quantity) AS cost,
    (oi.unit_price * oi.quantity * (1 - oi.discount / 100)) - (p.cost * oi.quantity) AS profit
FROM ecommerce_oltp.public.order_items oi
JOIN ecommerce_oltp.public.orders o ON oi.order_id = o.order_id
JOIN ecommerce_oltp.public.products p ON oi.product_id = p.product_id;

-- Проверка загрузки
SELECT COUNT(*) AS facts_count FROM fact_sales;

-- ============================================================================
-- 6. АГРЕГИРОВАННАЯ СТАТИСТИКА
-- ============================================================================

-- Общая статистика по хранилищу
SELECT 
    'Продажи всего' AS metric,
    COUNT(*)::text AS value
FROM fact_sales
UNION ALL
SELECT 'Выручка', ROUND(SUM(total_amount), 2)::text
FROM fact_sales
UNION ALL
SELECT 'Прибыль', ROUND(SUM(profit), 2)::text
FROM fact_sales
UNION ALL
SELECT 'Средний чек', ROUND(AVG(total_amount), 2)::text
FROM fact_sales
UNION ALL
SELECT 'Заказов', COUNT(DISTINCT order_id)::text
FROM fact_sales
UNION ALL
SELECT 'Покупателей', COUNT(DISTINCT user_id)::text
FROM fact_sales
UNION ALL
SELECT 'Товаров продано', SUM(quantity)::text
FROM fact_sales;

-- ============================================================================
-- 7. СОЗДАНИЕ ПРЕДСТАВЛЕНИЙ ДЛЯ УДОБСТВА АНАЛИЗА
-- ============================================================================

-- Представление: Ежедневные продажи
CREATE OR REPLACE VIEW v_daily_sales AS
SELECT 
    d.full_date,
    d.year,
    d.month,
    d.day,
    d.day_name,
    COUNT(DISTINCT fs.order_id) AS orders_count,
    SUM(fs.quantity) AS items_sold,
    SUM(fs.total_amount) AS revenue,
    SUM(fs.profit) AS profit,
    ROUND(AVG(fs.total_amount), 2) AS avg_order_value
FROM fact_sales fs
JOIN dim_date d ON fs.date_id = d.date_id
GROUP BY d.full_date, d.year, d.month, d.day, d.day_name
ORDER BY d.full_date;

-- Представление: Продажи по категориям
CREATE OR REPLACE VIEW v_category_sales AS
SELECT 
    p.category_name,
    p.parent_category_name,
    COUNT(DISTINCT fs.order_id) AS orders_count,
    SUM(fs.quantity) AS items_sold,
    SUM(fs.total_amount) AS revenue,
    SUM(fs.profit) AS profit,
    ROUND(AVG(fs.total_amount), 2) AS avg_item_price
FROM fact_sales fs
JOIN dim_product p ON fs.product_id = p.product_id
GROUP BY p.category_id, p.category_name, p.parent_category_name
ORDER BY revenue DESC;

-- Представление: Топ покупателей
CREATE OR REPLACE VIEW v_top_customers AS
SELECT 
    u.user_id,
    u.username,
    u.email,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.quantity) AS total_items,
    SUM(fs.total_amount) AS total_spent,
    SUM(fs.profit) AS total_profit,
    ROUND(AVG(fs.total_amount), 2) AS avg_order_value
FROM fact_sales fs
JOIN dim_user u ON fs.user_id = u.user_id
GROUP BY u.user_id, u.username, u.email
ORDER BY total_spent DESC;

-- Проверка представлений
SELECT * FROM v_daily_sales LIMIT 10;
SELECT * FROM v_category_sales;
SELECT * FROM v_top_customers LIMIT 10;
