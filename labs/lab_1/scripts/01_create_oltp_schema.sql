-- ============================================================================
-- Скрипт создания OLTP-схемы базы данных интернет-магазина
-- ============================================================================

-- Переключиться на базу данных ecommerce_oltp
-- \c ecommerce_oltp;

-- ============================================================================
-- 1. СОЗДАНИЕ ТАБЛИЦ
-- ============================================================================

-- Таблица пользователей
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица адресов
CREATE TABLE IF NOT EXISTS addresses (
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
CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    parent_category_id INTEGER REFERENCES categories(category_id),
    category_name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Таблица товаров
CREATE TABLE IF NOT EXISTS products (
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
CREATE TABLE IF NOT EXISTS orders (
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
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10, 2) NOT NULL,
    discount NUMERIC(5, 2) DEFAULT 0 CHECK (discount >= 0 AND discount <= 100)
);

-- Таблица платежей
CREATE TABLE IF NOT EXISTS payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    payment_method VARCHAR(50) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    amount NUMERIC(12, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    transaction_id VARCHAR(100)
);

-- ============================================================================
-- 2. СОЗДАНИЕ ИНДЕКСОВ
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_addresses_user ON addresses(user_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_price ON products(price);
CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(order_status);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id);

-- ============================================================================
-- 3. ПРОСМОТР СОЗДАННЫХ ТАБЛИЦ
-- ============================================================================

\dt

-- Просмотр структуры таблиц
\d users
\d orders
\d order_items
