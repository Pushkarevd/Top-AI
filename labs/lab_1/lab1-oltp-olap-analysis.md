# Лабораторное занятие №1
## Проектирование архитектуры хранения данных: сравнительный анализ OLTP- и OLAP-систем, анализ плана запроса

**Дисциплина:** Технологии хранения и обработки больших данных

**Время выполнения:** 4 академических часа (180 минут)

---

## 1. ЦЕЛИ И ЗАДАЧИ

### 1.1. Цель работы
Изучить архитектурные различия между OLTP- и OLAP-системами, приобрести практические навыки проектирования схем данных для различных типов нагрузок, научиться анализировать планы выполнения запросов для оптимизации производительности.

### 1.2. Задачи
- Изучить теоретические основы OLTP и OLAP систем
- Спроектировать и реализовать схему данных для OLTP-системы
- Спроектировать и реализовать схему данных для OLAP-системы (хранилище данных)
- Провести сравнительный анализ производительности запросов
- Научиться читать и анализировать планы выполнения запросов
- Оптимизировать запросы на основе анализа планов выполнения

---

## 2. ТЕОРЕТИЧЕСКИЕ СВЕДЕНИЯ

### 2.1. OLTP-системы (Online Transaction Processing)

**OLTP** — системы обработки транзакций в реальном времени, предназначенные для выполнения большого количества коротких транзакций.

**Характерные особенности:**
- Нормализованная структура данных (3NF и выше)
- Частые операции INSERT, UPDATE, DELETE
- Короткие транзакции с быстрым откликом
- Поддержка ACID-свойств
- Ориентация на текущие данные
- Примеры: банковские системы, системы бронирования, CRM, ERP

**Преимущества:**
- Минимизация избыточности данных
- Целостность данных
- Быстрая запись и обновление

**Недостатки:**
- Сложные аналитические запросы требуют множественных JOIN
- Низкая производительность для аналитики

### 2.2. OLAP-системы (Online Analytical Processing)

**OLAP** — системы аналитической обработки данных, предназначенные для выполнения сложных запросов к большим объёмам данных.

**Характерные особенности:**
- Денормализованная структура (схема «звезда», «снежинка»)
- Преимущественно операции SELECT
- Длинные транзакции с обработкой больших объёмов данных
- Ориентация на исторические данные
- Многомерная модель данных
- Примеры: хранилища данных, бизнес-аналитика, отчётность

**Преимущества:**
- Быстрое выполнение аналитических запросов
- Удобство для бизнес-пользователей
- Поддержка агрегаций

**Недостатки:**
- Избыточность данных
- Медленная загрузка и обновление

### 2.3. Сравнительная таблица

| Критерий | OLTP | OLAP |
|----------|------|------|
| **Назначение** | Операционная деятельность | Аналитика и отчётность |
| **Структура данных** | Нормализованная | Денормализованная |
| **Тип запросов** | Короткие, простые | Длинные, сложные |
| **Операции** | INSERT, UPDATE, DELETE | SELECT |
| **Объём данных** | ГБ - ТБ | ТБ - ПБ |
| **Время отклика** | Миллисекунды | Секунды - минуты |
| **Пользователи** | Операционные сотрудники | Аналитики, менеджеры |

### 2.4. План выполнения запроса

**План выполнения** — это последовательность операций, которые СУБД выполняет для получения результата запроса.

**Ключевые элементы плана:**
- **Seq Scan** — последовательное сканирование таблицы
- **Index Scan** — сканирование с использованием индекса
- **Index Only Scan** — получение данных только из индекса
- **Nested Loop** — соединение методом вложенных циклов
- **Hash Join** — соединение с использованием хеш-таблицы
- **Merge Join** — соединением слиянием
- **Sort** — сортировка данных
- **Aggregate** — агрегация данных

**Метрики для анализа:**
- **Cost** — оценочная стоимость операции
- **Actual Time** — фактическое время выполнения
- **Rows** — количество обработанных строк
- **Width** — средний размер строки в байтах

---

## 3. ОБОРУДОВАНИЕ И ИНСТРУМЕНТАЛЬНОЕ ОБЕСПЕЧЕНИЕ

### 3.1. Программное обеспечение
- PostgreSQL 14+ (или другая реляционная СУБД с поддержкой EXPLAIN ANALYZE)
- pgAdmin 4 или DBeaver (опционально)
- Терминал/командная строка

### 3.2. Исходные данные
Генератор тестовых данных будет создан в ходе выполнения работы.

---

## 4. ПОРЯДОК ВЫПОЛНЕНИЯ РАБОТЫ

### ЧАСТЬ 1. Проектирование и создание OLTP-системы (60 минут)

#### Шаг 1.1. Создание базы данных

```sql
-- Создайте базу данных для OLTP-системы
CREATE DATABASE ecommerce_oltp;
\c ecommerce_oltp;
```

#### Шаг 1.2. Проектирование нормализованной схемы

Создайте следующую схему данных (3NF):

```sql
-- Таблица пользователей
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица адресов
CREATE TABLE addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    address_type VARCHAR(20) CHECK (address_type IN ('shipping', 'billing')),
    country VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    street VARCHAR(100) NOT NULL,
    building VARCHAR(10),
    apartment VARCHAR(10),
    postal_code VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE
);

-- Таблица категорий товаров
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    parent_category_id INTEGER REFERENCES categories(category_id),
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Таблица товаров
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL REFERENCES categories(category_id),
    product_name VARCHAR(200) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    cost NUMERIC(10, 2) CHECK (cost >= 0),
    quantity_in_stock INTEGER NOT NULL DEFAULT 0 CHECK (quantity_in_stock >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица заказов
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(user_id),
    shipping_address_id INTEGER REFERENCES addresses(address_id),
    billing_address_id INTEGER REFERENCES addresses(address_id),
    order_status VARCHAR(20) NOT NULL DEFAULT 'pending' 
        CHECK (order_status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP,
    total_amount NUMERIC(12, 2)
);

-- Таблица позиций заказа
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    discount NUMERIC(5, 2) DEFAULT 0 CHECK (discount >= 0 AND discount <= 100)
);

-- Таблица платежей
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    amount NUMERIC(12, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(100)
);

-- Создайте индексы для оптимизации запросов
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_addresses_user ON addresses(user_id);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);
CREATE INDEX idx_payments_order ON payments(order_id);
```

#### Шаг 1.3. Заполнение данными

Создайте скрипт для генерации тестовых данных:

```sql
-- Генерация пользователей (1000 записей)
INSERT INTO users (username, email, phone)
SELECT 
    'user_' || i,
    'user' || i || '@example.com',
    '+7-900-' || LPAD(i::text, 7, '0')
FROM generate_series(1, 1000) AS i;

-- Генерация категорий
INSERT INTO categories (category_name, description) VALUES
('Электроника', 'Электронные устройства и аксессуары'),
('Одежда', 'Одежда и обувь'),
('Книги', 'Книги и печатная продукция'),
('Дом и сад', 'Товары для дома и сада'),
('Спорт', 'Спортивные товары');

INSERT INTO categories (parent_category_id, category_name, description) VALUES
(1, 'Смартфоны', 'Мобильные телефоны'),
(1, 'Ноутбуки', 'Портативные компьютеры'),
(1, 'Планшеты', 'Планшетные компьютеры'),
(2, 'Мужская одежда', 'Одежда для мужчин'),
(2, 'Женская одежда', 'Одежда для женщин');

-- Генерация товаров (500 записей)
INSERT INTO products (category_id, product_name, description, price, cost, quantity_in_stock)
SELECT 
    (random() * 10 + 1)::integer AS category_id,
    'Product ' || i,
    'Description for product ' || i,
    (random() * 10000 + 100)::numeric(10,2) AS price,
    (random() * 5000 + 50)::numeric(10,2) AS cost,
    (random() * 1000)::integer AS quantity_in_stock
FROM generate_series(1, 500) AS i;

-- Генерация заказов (10000 записей)
INSERT INTO orders (user_id, shipping_address_id, order_status, order_date, total_amount)
SELECT 
    (random() * 999 + 1)::integer AS user_id,
    NULL, -- shipping_address_id
    (ARRAY['pending', 'confirmed', 'shipped', 'delivered'])[floor(random() * 4 + 1)::integer] AS order_status,
    CURRENT_TIMESTAMP - (random() * 365 || ' days')::interval AS order_date,
    0 -- будет обновлено
FROM generate_series(1, 10000) AS i;

-- Генерация позиций заказа (30000 записей)
INSERT INTO order_items (order_id, product_id, quantity, unit_price, discount)
SELECT 
    (random() * 9999 + 1)::integer AS order_id,
    (random() * 499 + 1)::integer AS product_id,
    (random() * 5 + 1)::integer AS quantity,
    (SELECT price FROM products WHERE product_id = (random() * 499 + 1)::integer LIMIT 1) AS unit_price,
    (random() * 20)::numeric(5,2) AS discount
FROM generate_series(1, 30000) AS i;

-- Обновление общей суммы заказов
UPDATE orders o
SET total_amount = (
    SELECT COALESCE(SUM(oi.unit_price * oi.quantity * (1 - oi.discount / 100)), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);

-- Генерация платежей
INSERT INTO payments (order_id, payment_method, payment_status, amount, transaction_id)
SELECT 
    order_id,
    (ARRAY['credit_card', 'debit_card', 'paypal', 'bank_transfer'])[floor(random() * 4 + 1)::integer],
    (ARRAY['pending', 'completed', 'failed'])[floor(random() * 3 + 1)::integer],
    total_amount,
    'TXN' || LPAD(order_id::text, 10, '0')
FROM orders
WHERE order_status != 'pending';
```

#### Шаг 1.4. Тестовые запросы для OLTP

Выполните следующие запросы и проанализируйте их планы:

```sql
-- Запрос 1: Поиск пользователя по email
EXPLAIN ANALYZE
SELECT * FROM users WHERE email = 'user500@example.com';

-- Запрос 2: Получение заказа со всеми деталями
EXPLAIN ANALYZE
SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    u.username,
    u.email,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    oi.discount
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_id = 100;

-- Запрос 3: Обновление статуса заказа (транзакция)
EXPLAIN ANALYZE
BEGIN;
UPDATE orders 
SET order_status = 'shipped', shipped_date = CURRENT_TIMESTAMP
WHERE order_id = 100;
COMMIT;

-- Запрос 4: Добавление нового заказа
EXPLAIN ANALYZE
INSERT INTO orders (user_id, order_status, total_amount)
VALUES (1, 'pending', 5000.00)
RETURNING order_id;
```

---

### ЧАСТЬ 2. Проектирование и создание OLAP-системы (60 минут)

#### Шаг 2.1. Создание базы данных для хранилища

```sql
-- Создайте базу данных для OLAP-системы
CREATE DATABASE ecommerce_olap;
\c ecommerce_olap;
```

#### Шаг 2.2. Проектирование денормализованной схемы (схема «звезда»)

```sql
-- Таблица фактов: продажи
CREATE TABLE fact_sales (
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
    profit NUMERIC(12, 2) NOT NULL
);

-- Измерение: время
CREATE TABLE dim_date (
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

-- Измерение: пользователь
CREATE TABLE dim_user (
    user_key SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    username VARCHAR(50),
    email VARCHAR(100),
    registration_date DATE,
    city VARCHAR(50),
    country VARCHAR(50)
);

-- Измерение: товар
CREATE TABLE dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(200),
    category_id INTEGER,
    category_name VARCHAR(100),
    parent_category_name VARCHAR(100),
    current_price NUMERIC(10, 2),
    current_cost NUMERIC(10, 2)
);

-- Измерение: статус заказа
CREATE TABLE dim_order_status (
    status_key SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_status VARCHAR(20),
    order_date TIMESTAMP,
    shipped_date TIMESTAMP,
    delivered_date TIMESTAMP
);

-- Создайте индексы для измерений
CREATE INDEX idx_fact_sales_user ON fact_sales(user_id);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_date ON fact_sales(date_id);
CREATE INDEX idx_fact_sales_category ON fact_sales(category_id);
```

#### Шаг 2.3. Заполнение хранилища данных (ETL-процесс)

```sql
-- Заполнение измерения времени
INSERT INTO dim_date (date_id, full_date, day, month, year, quarter, day_of_week, day_name, month_name, is_weekend)
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
    EXTRACT(DOW FROM d) IN (0, 6) AS is_weekend
FROM generate_series(
    CURRENT_DATE - 365,
    CURRENT_DATE,
    '1 day'::interval
) AS d;

-- Заполнение измерения пользователей
INSERT INTO dim_user (user_id, username, email, registration_date)
SELECT 
    user_id,
    username,
    email,
    created_at::date
FROM ecommerce_oltp.public.users;

-- Заполнение измерения товаров
INSERT INTO dim_product (product_id, product_name, category_id, category_name, current_price, current_cost)
SELECT 
    p.product_id,
    p.product_name,
    c.category_id,
    c.category_name,
    p.price,
    p.cost
FROM ecommerce_oltp.public.products p
JOIN ecommerce_oltp.public.categories c ON p.category_id = c.category_id;

-- Заполнение таблицы фактов
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
    p.cost * oi.quantity AS cost,
    (oi.unit_price * oi.quantity * (1 - oi.discount / 100)) - (p.cost * oi.quantity) AS profit
FROM ecommerce_oltp.public.order_items oi
JOIN ecommerce_oltp.public.orders o ON oi.order_id = o.order_id
JOIN ecommerce_oltp.public.products p ON oi.product_id = p.product_id;
```

#### Шаг 2.4. Тестовые запросы для OLAP

Выполните следующие аналитические запросы:

```sql
-- Запрос 1: Продажи по месяцам
EXPLAIN ANALYZE
SELECT 
    d.year,
    d.month,
    d.month_name,
    COUNT(*) AS total_orders,
    SUM(fs.quantity) AS total_quantity,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.profit) AS total_profit,
    AVG(fs.total_amount) AS avg_order_value
FROM fact_sales fs
JOIN dim_date d ON fs.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- Запрос 2: Топ-10 товаров по выручке
EXPLAIN ANALYZE
SELECT 
    p.product_name,
    p.category_name,
    SUM(fs.quantity) AS total_quantity_sold,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.profit) AS total_profit
FROM fact_sales fs
JOIN dim_product p ON fs.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- Запрос 3: Анализ по категориям товаров
EXPLAIN ANALYZE
SELECT 
    p.category_name,
    COUNT(DISTINCT fs.order_id) AS unique_orders,
    SUM(fs.quantity) AS total_quantity,
    SUM(fs.total_amount) AS revenue,
    SUM(fs.profit) AS profit,
    ROUND(AVG(fs.total_amount), 2) AS avg_item_price
FROM fact_sales fs
JOIN dim_product p ON fs.product_id = p.product_id
GROUP BY p.category_name
ORDER BY revenue DESC;

-- Запрос 4: Продажи по дням недели
EXPLAIN ANALYZE
SELECT 
    d.day_name,
    d.is_weekend,
    COUNT(*) AS transactions,
    SUM(fs.total_amount) AS revenue,
    ROUND(AVG(fs.total_amount), 2) AS avg_transaction
FROM fact_sales fs
JOIN dim_date d ON fs.date_id = d.date_id
GROUP BY d.day_name, d.is_weekend
ORDER BY d.day_of_week;
```

---

### ЧАСТЬ 3. Сравнительный анализ производительности (45 минут)

#### Шаг 3.1. Выполнение одинаковых запросов в OLTP и OLAP

Выполните следующие запросы в обеих базах данных и сравните время выполнения:

**Запрос А: Общая выручка по месяцам**

```sql
-- В OLTP (ecommerce_oltp)
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', o.order_date) AS month,
    COUNT(*) AS order_count,
    SUM(oi.unit_price * oi.quantity * (1 - oi.discount / 100)) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;

-- В OLAP (ecommerce_olap)
EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('month', d.full_date) AS month,
    COUNT(DISTINCT fs.order_id) AS order_count,
    SUM(fs.total_amount) AS revenue
FROM fact_sales fs
JOIN dim_date d ON fs.date_id = d.date_id
GROUP BY DATE_TRUNC('month', d.full_date)
ORDER BY month;
```

**Запрос Б: Статистика по пользователям**

```sql
-- В OLTP
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.unit_price * oi.quantity * (1 - oi.discount / 100)) AS total_spent
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_spent DESC
LIMIT 20;

-- В OLAP
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT fs.order_id) AS total_orders,
    SUM(fs.total_amount) AS total_spent
FROM fact_sales fs
JOIN dim_user u ON fs.user_id = u.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT fs.order_id) > 1
ORDER BY total_spent DESC
LIMIT 20;
```

#### Шаг 3.2. Заполнение таблицы сравнения

| Запрос | OLTP время (мс) | OLAP время (мс) | Ускорение (раз) |
|--------|-----------------|-----------------|-----------------|
| Выручка по месяцам | | | |
| Статистика пользователей | | | |
| Топ товаров | | | |
| Анализ по категориям | | | |

---

### ЧАСТЬ 4. Анализ планов выполнения (15 минут)

#### Шаг 4.1. Анализ плана сложного запроса

Выполните запрос с подробным анализом плана:

```sql
-- В OLTP базе
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT 
    c.category_name,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(oi.quantity) AS items_sold,
    SUM(oi.unit_price * oi.quantity) AS gross_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '6 months'
    AND o.order_status = 'delivered'
GROUP BY c.category_id, c.category_name
HAVING SUM(oi.unit_price * oi.quantity) > 10000
ORDER BY gross_revenue DESC;
```

#### Шаг 4.2. Вопросы для анализа

Проанализируйте план выполнения и ответьте на вопросы:

1. **Какие типы сканирования используются?** (Seq Scan, Index Scan, Index Only Scan)
   - ___________________________________________________________________

2. **Какие соединения применяются?** (Nested Loop, Hash Join, Merge Join)
   - ___________________________________________________________________

3. **Какая операция самая дорогая по стоимости (cost)?**
   - ___________________________________________________________________

4. **Сколько строк было обработано на каждом этапе?**
   - ___________________________________________________________________

5. **Предложите оптимизацию запроса (добавление индексов, изменение структуры):**
   - ___________________________________________________________________
   - ___________________________________________________________________

---

## 5. СОДЕРЖАНИЕ ОТЧЁТА

Отчёт по лабораторной работе должен содержать:

1. **Титульный лист** (номер работы, название, ФИО, группа)

2. **Цель работы**

3. **Схемы данных:**
   - ER-диаграмма OLTP-системы
   - Схема «звезда» OLAP-системы

4. **Результаты выполнения:**
   - Скриншоты выполненных запросов
   - Планы выполнения запросов с анализом
   - Таблица сравнения производительности

5. **Анализ планов выполнения:**
   - Ответы на вопросы из Части 4
   - Предложения по оптимизации

6. **Выводы:**
   - Когда целесообразно использовать OLTP
   - Когда целесообразно использовать OLAP
   - Какие преимущества показала каждая архитектура

---

## 6. КОНТРОЛЬНЫЕ ВОПРОСЫ

1. В чём основное различие между OLTP и OLAP системами?

2. Почему OLTP-системы используют нормализованную структуру данных?

3. Что такое схема «звезда» и какие у неё преимущества?

4. Объясните разницу между Seq Scan и Index Scan.

5. Какие факторы влияют на выбор типа соединения (Nested Loop, Hash Join, Merge Join)?

6. Что означает метрика «cost» в плане выполнения запроса?

7. Почему аналитические запросы выполняются быстрее в OLAP-системах?

8. Какие проблемы могут возникнуть при использовании только OLTP для аналитики?

9. Что такое ETL-процесс и зачем он нужен?

10. Когда имеет смысл создавать хранилище данных?

---

## 7. КРИТЕРИИ ОЦЕНИВАНИЯ

| Критерий | Баллы |
|----------|-------|
| Создание OLTP-схемы | 15 |
| Создание OLAP-схемы | 15 |
| Заполнение данными | 10 |
| Выполнение тестовых запросов | 20 |
| Сравнительный анализ производительности | 20 |
| Анализ планов выполнения | 15 |
| Качество отчёта и выводов | 5 |
| **Итого** | **100** |

**Шкала оценок:**
- 90-100 баллов: «Отлично»
- 75-89 баллов: «Хорошо»
- 60-74 баллов: «Удовлетворительно»
- Менее 60 баллов: «Неудовлетворительно»

---

## 8. ДОПОЛНИТЕЛЬНЫЕ ЗАДАНИЯ (ПОВЫШЕННАЯ СЛОЖНОСТЬ)

### Задание 1: Оптимизация запросов
Найдите 3 запроса с наибольшим временем выполнения и оптимизируйте их с помощью:
- Добавления индексов
- Переписывания запроса
- Изменения структуры данных

### Задание 2: Создание материализованных представлений
Создайте материализованные представления для часто используемых аналитических запросов в OLAP-системе. Сравните производительность до и после.

```sql
-- Пример материализованного представления
CREATE MATERIALIZED VIEW mv_monthly_sales AS
SELECT 
    d.year,
    d.month,
    p.category_name,
    COUNT(DISTINCT fs.order_id) AS orders,
    SUM(fs.total_amount) AS revenue,
    SUM(fs.profit) AS profit
FROM fact_sales fs
JOIN dim_date d ON fs.date_id = d.date_id
JOIN dim_product p ON fs.product_id = p.product_id
GROUP BY d.year, d.month, p.category_name;

-- Обновление представления
REFRESH MATERIALIZED VIEW mv_monthly_sales;
```

### Задание 3: Параллельное выполнение запросов
Исследуйте возможности параллельного выполнения запросов в PostgreSQL. Включите параллелизм и сравните производительность сложных аналитических запросов.

```sql
-- Проверка настроек параллелизма
SHOW max_parallel_workers_per_gather;
SHOW max_parallel_workers;

-- Изменение настроек (требуются права суперпользователя)
SET max_parallel_workers_per_gather = 4;
```

---

## ПРИЛОЖЕНИЕ А. ЧЕК-ЛИСТ ПРОВЕРКИ

- [ ] Создана база данных ecommerce_oltp
- [ ] Созданы все таблицы OLTP-схемы
- [ ] Созданы индексы для OLTP
- [ ] Данные сгенерированы и загружены
- [ ] Создана база данных ecommerce_olap
- [ ] Созданы таблицы фактов и измерений
- [ ] Выполнен ETL-процесс
- [ ] Выполнены все тестовые запросы
- [ ] Заполнена таблица сравнения производительности
- [ ] Проанализированы планы выполнения
- [ ] Ответы на контрольные вопросы
- [ ] Сформирован отчёт

---

**Методические указания разработал:** [ФИО преподавателя]

**Дата утверждения:** «___» __________ 20__ г.
