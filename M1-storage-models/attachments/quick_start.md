# Быстрый старт для лабораторной работы №1

## 1. Установка PostgreSQL

### Вариант A: Docker (рекомендуется)
```bash
# Запуск PostgreSQL
docker run --name postgres-lab -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:15

# Проверка
docker ps
```

### Вариант B: Локальная установка
- Windows/Mac: https://www.postgresql.org/download/
- Linux: `sudo apt-get install postgresql postgresql-contrib`

---

## 2. Создание баз данных

```bash
# Подключитесь к PostgreSQL
psql -U postgres

# Создайте базы данных
CREATE DATABASE ecommerce_oltp;
CREATE DATABASE ecommerce_olap;

# Выход
\q
```

---

## 3. Запуск скриптов

```bash
# Перейдите в директорию со скриптами
cd labs/scripts

# OLTP: Создание схемы
psql -U postgres -d ecommerce_oltp -f 01_create_oltp_schema.sql

# OLTP: Генерация данных (5-10 минут)
psql -U postgres -d ecommerce_oltp -f 02_seed_oltp_data.sql

# OLAP: Создание схемы
psql -U postgres -d ecommerce_olap -f 03_create_olap_schema.sql

# OLAP: ETL-процесс (5-10 минут)
psql -U postgres -d ecommerce_olap -f 04_etl_to_olap.sql
```

---

## 4. Проверка данных

```bash
# Подключитесь к OLTP
psql -U postgres -d ecommerce_oltp

# Проверьте количество записей
SELECT 
    'users' AS table_name, COUNT(*) AS count FROM users
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

# Выход
\q

# Подключитесь к OLAP
psql -U postgres -d ecommerce_olap

# Проверьте хранилище
SELECT 
    'fact_sales' AS table_name, COUNT(*) AS count FROM fact_sales
UNION ALL SELECT 'dim_user', COUNT(*) FROM dim_user
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date;

# Выход
\q
```

---

## 5. Начало работы

Откройте файл [lab1-oltp-olap-analysis.md](lab1-oltp-olap-analysis.md) и следуйте инструкциям.

---

## Решение проблем

### Ошибка: "psql: command not found"
Установите PostgreSQL или добавьте путь к psql в PATH:
```bash
# Windows
set PATH=%PATH%;C:\Program Files\PostgreSQL\15\bin

# Linux/Mac
export PATH=$PATH:/usr/lib/postgresql/15/bin
```

### Ошибка: "connection refused"
Убедитесь, что PostgreSQL запущен:
```bash
# Docker
docker ps | grep postgres

# Linux
sudo systemctl status postgresql

# Windows/Mac
Проверьте в системном трее
```

### Ошибка: "database does not exist"
Создайте базы данных (см. шаг 2).

### Долгая генерация данных
Это нормально! Генерация 30000+ записей может занять 5-10 минут.

---

## Полезные команды psql

```sql
-- Список баз данных
\l

-- Список таблиц
\dt

-- Структура таблицы
\d table_name

-- Выполнить SQL-запрос из файла
\i файл.sql

-- Вывод в файл
\o output.txt
-- ваш запрос
\o

-- Выход
\q
```

---

## Контакты

При возникновении проблем обращайтесь:
- Email: [преподаватель@вуз.ру]
- Консультации: [время и место]
