-- ============================================================================
-- Скрипт генерации тестовых данных для OLTP-системы
-- ============================================================================

-- Переключиться на базу данных ecommerce_oltp
-- \c ecommerce_oltp;

-- ============================================================================
-- 1. ГЕНЕРАЦИЯ ПОЛЬЗОВАТЕЛЕЙ (1000 записей)
-- ============================================================================

INSERT INTO users (username, email, phone)
SELECT 
    'user_' || i,
    'user' || i || '@example.com',
    '+7-900-' || LPAD(i::text, 7, '0')
FROM generate_series(1, 1000) AS i;

-- Проверка
SELECT COUNT(*) AS users_count FROM users;

-- ============================================================================
-- 2. ГЕНЕРАЦИЯ КАТЕГОРИЙ
-- ============================================================================

-- Основные категории
INSERT INTO categories (category_name, description) VALUES
('Электроника', 'Электронные устройства и аксессуары'),
('Одежда', 'Одежда и обувь'),
('Книги', 'Книги и печатная продукция'),
('Дом и сад', 'Товары для дома и сада'),
('Спорт', 'Спортивные товары');

-- Подкатегории
INSERT INTO categories (parent_category_id, category_name, description) VALUES
(1, 'Смартфоны', 'Мобильные телефоны'),
(1, 'Ноутбуки', 'Портативные компьютеры'),
(1, 'Планшеты', 'Планшетные компьютеры'),
(1, 'Аксессуары', 'Аксессуары для электроники'),
(2, 'Мужская одежда', 'Одежда для мужчин'),
(2, 'Женская одежда', 'Одежда для женщин'),
(2, 'Обувь', 'Обувь всех видов'),
(3, 'Художественная литература', 'Романы, повести, рассказы'),
(3, 'Научная литература', 'Научные и учебные издания'),
(4, 'Мебель', 'Домашняя мебель'),
(4, 'Декор', 'Предметы декора'),
(5, 'Фитнес', 'Оборудование для фитнеса'),
(5, 'Командные виды', 'Инвентарь для командных видов спорта');

-- Проверка
SELECT 
    c.category_id,
    c.category_name,
    c.parent_category_id,
    p.category_name AS parent_name
FROM categories c
LEFT JOIN categories p ON c.parent_category_id = p.category_id
ORDER BY c.category_id;

-- ============================================================================
-- 3. ГЕНЕРАЦИЯ ТОВАРОВ (500 записей)
-- ============================================================================

INSERT INTO products (category_id, product_name, description, price, cost, quantity_in_stock)
SELECT 
    (random() * 10 + 1)::integer AS category_id,
    'Product ' || i,
    'Description for product ' || i || '. This is a detailed description of the product.',
    (random() * 10000 + 100)::numeric(10,2) AS price,
    (random() * 5000 + 50)::numeric(10,2) AS cost,
    (random() * 1000)::integer AS quantity_in_stock
FROM generate_series(1, 500) AS i;

-- Проверка
SELECT 
    c.category_name,
    COUNT(*) AS products_count,
    ROUND(AVG(p.price), 2) AS avg_price,
    SUM(p.quantity_in_stock) AS total_stock
FROM products p
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_id, c.category_name
ORDER BY products_count DESC;

-- ============================================================================
-- 4. ГЕНЕРАЦИЯ ЗАКАЗОВ (10000 записей)
-- ============================================================================

INSERT INTO orders (user_id, shipping_address_id, order_status, order_date, total_amount)
SELECT 
    (random() * 999 + 1)::integer AS user_id,
    NULL, -- shipping_address_id
    (ARRAY['pending', 'confirmed', 'shipped', 'delivered'])[floor(random() * 4 + 1)::integer] AS order_status,
    CURRENT_TIMESTAMP - (random() * 365 || ' days')::interval AS order_date,
    0 -- будет обновлено после добавления позиций
FROM generate_series(1, 10000) AS i;

-- Проверка
SELECT 
    order_status,
    COUNT(*) AS orders_count,
    ROUND(AVG(total_amount), 2) AS avg_amount
FROM orders
GROUP BY order_status
ORDER BY orders_count DESC;

-- ============================================================================
-- 5. ГЕНЕРАЦИЯ ПОЗИЦИЙ ЗАКАЗА (30000 записей)
-- ============================================================================

-- Временная таблица для эффективной генерации
CREATE TEMP TABLE temp_products AS 
SELECT product_id, price, cost FROM products;

INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
SELECT 
    (random() * 9999 + 1)::integer AS order_id,
    (random() * 499 + 1)::integer AS product_id,
    (random() * 5 + 1)::integer AS quantity,
    (SELECT price FROM temp_products WHERE product_id = (random() * 499 + 1)::integer LIMIT 1) AS unit_price,
    (random() * 20)::numeric(5,2) AS discount
FROM generate_series(1, 30000) AS i;

DROP TABLE temp_products;

-- Проверка
SELECT 
    COUNT(*) AS total_items,
    COUNT(DISTINCT order_id) AS orders_with_items,
    ROUND(AVG(quantity), 2) AS avg_quantity,
    ROUND(AVG(unit_price), 2) AS avg_price
FROM order_items;

-- ============================================================================
-- 6. ОБНОВЛЕНИЕ ОБЩЕЙ СУММЫ ЗАКАЗОВ
-- ============================================================================

UPDATE orders o
SET total_amount = (
    SELECT COALESCE(SUM(oi.unit_price * oi.quantity * (1 - oi.discount / 100)), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);

-- Проверка распределения сумм заказов
SELECT 
    CASE 
        WHEN total_amount < 500 THEN '0-500'
        WHEN total_amount < 1000 THEN '500-1000'
        WHEN total_amount < 5000 THEN '1000-5000'
        WHEN total_amount < 10000 THEN '5000-10000'
        ELSE '10000+'
    END AS amount_range,
    COUNT(*) AS orders_count,
    ROUND(AVG(total_amount), 2) AS avg_amount
FROM orders
GROUP BY amount_range
ORDER BY MIN(total_amount);

-- ============================================================================
-- 7. ГЕНЕРАЦИЯ ПЛАТЕЖЕЙ
-- ============================================================================

INSERT INTO payments (order_id, payment_method, payment_status, amount, transaction_id)
SELECT 
    order_id,
    (ARRAY['credit_card', 'debit_card', 'paypal', 'bank_transfer'])[floor(random() * 4 + 1)::integer],
    (ARRAY['pending', 'completed', 'failed'])[floor(random() * 3 + 1)::integer],
    total_amount,
    'TXN' || LPAD(order_id::text, 10, '0')
FROM orders
WHERE order_status != 'pending';

-- Проверка
SELECT 
    payment_method,
    payment_status,
    COUNT(*) AS payments_count,
    ROUND(SUM(amount), 2) AS total_amount
FROM payments
GROUP BY payment_method, payment_status
ORDER BY payments_count DESC;

-- ============================================================================
-- 8. ИТОГОВАЯ СТАТИСТИКА
-- ============================================================================

SELECT 
    'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'categories', COUNT(*) FROM categories
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
ORDER BY row_count DESC;
