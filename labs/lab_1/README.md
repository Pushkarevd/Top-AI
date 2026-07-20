# Лабораторные работы
## Технологии хранения и обработки больших данных

---

## Список лабораторных работ

### Лабораторная работа №1
**Тема:** Проектирование архитектуры хранения данных: сравнительный анализ OLTP- и OLAP-систем, анализ плана запроса

**Файлы:**
- [lab1-oltp-olap-analysis.md](lab1-oltp-olap-analysis.md) - методические указания
- [report_template.md](report_template.md) - шаблон отчёта

**Скрипты:**
- [scripts/01_create_oltp_schema.sql](scripts/01_create_oltp_schema.sql) - создание OLTP-схемы
- [scripts/02_seed_oltp_data.sql](scripts/02_seed_oltp_data.sql) - генерация тестовых данных
- [scripts/03_create_olap_schema.sql](scripts/03_create_olap_schema.sql) - создание OLAP-схемы
- [scripts/04_etl_to_olap.sql](scripts/04_etl_to_olap.sql) - ETL-процесс заполнения хранилища

---

## Требования к выполнению

### Программное обеспечение

1. **PostgreSQL 14+**
   - Установка: https://www.postgresql.org/download/
   - Или используйте Docker:
   ```bash
   docker run --name postgres-lab -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:15
   ```

2. **Клиент для работы с БД** (на выбор):
   - pgAdmin 4
   - DBeaver
   - psql (командная строка)
   - DataGrip

### Подготовка окружения

```bash
# 1. Создайте базу данных для OLTP
createdb -U postgres ecommerce_oltp

# 2. Создайте базу данных для OLAP
createdb -U postgres ecommerce_olap

# 3. Выполните скрипты для OLTP
psql -U postgres -d ecommerce_oltp -f scripts/01_create_oltp_schema.sql
psql -U postgres -d ecommerce_oltp -f scripts/02_seed_oltp_data.sql

# 4. Выполните скрипты для OLAP
psql -U postgres -d ecommerce_olap -f scripts/03_create_olap_schema.sql
psql -U postgres -d ecommerce_olap -f scripts/04_etl_to_olap.sql
```

---

## Порядок выполнения работы

### Этап 1. Подготовка (15 минут)
1. Установите PostgreSQL и клиентское ПО
2. Создайте базы данных
3. Выполните скрипты создания схем
4. Проверьте корректность загрузки данных

### Этап 2. OLTP-система (60 минут)
1. Изучите структуру нормализованной схемы
2. Выполните тестовые запросы из методички
3. Проанализируйте планы выполнения
4. Сделайте скриншоты результатов

### Этап 3. OLAP-система (60 минут)
1. Изучите структуру хранилища данных
2. Выполните аналитические запросы
3. Сравните производительность с OLTP
4. Заполните таблицу сравнения

### Этап 4. Анализ и отчёт (45 минут)
1. Проанализируйте планы выполнения
2. Ответьте на контрольные вопросы
3. Сформулируйте выводы
4. Оформите отчёт по шаблону

---

## Критерии оценивания

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

## Часто задаваемые вопросы

### Q: Как подключиться к базе данных через psql?

```bash
psql -U postgres -d ecommerce_oltp
```

### Q: Как просмотреть список таблиц?

```sql
\dt
```

### Q: Как посмотреть структуру таблицы?

```sql
\d table_name
```

### Q: Как выполнить скрипт из файла?

```sql
\i путь/к/файлу.sql
```

Или из командной строки:
```bash
psql -U postgres -d ecommerce_oltp -f script.sql
```

### Q: Как экспортировать план выполнения запроса?

```sql
-- В psql
\o plan_output.txt
EXPLAIN ANALYZE SELECT ...;
\o
```

### Q: Сколько данных должно быть сгенерировано?

- users: 1000 записей
- products: 500 записей
- orders: 10000 записей
- order_items: 30000 записей

### Q: Что делать, если данные не загружаются?

1. Проверьте, создана ли схема
2. Проверьте права доступа к базе данных
3. Посмотрите текст ошибки
4. Убедитесь, что OLTP-база заполнена перед ETL в OLAP

---

## Дополнительные ресурсы

### Документация PostgreSQL
- [EXPLAIN](https://www.postgresql.org/docs/current/sql-explain.html)
- [CREATE INDEX](https://www.postgresql.org/docs/current/sql-createindex.html)
- [Query Planning](https://www.postgresql.org/docs/current/using-explain.html)

### Статьи
- [OLTP vs OLAP: What's the Difference?](https://www.altexsoft.com/blog/oltp-vs-olap/)
- [Understanding PostgreSQL Query Plans](https://www.postgresql.org/docs/current/using-explain.html)
- [Data Warehousing Concepts](https://docs.microsoft.com/en-us/analysis-services/multidimensional-modeling/olap-and-the-conceptual-framework)

### Книги
- "PostgreSQL. Основы языка SQL" - В. Федоров
- "Designing Data-Intensive Applications" - Martin Kleppmann

---

## Контакты преподавателя

**Email:** [укажите email]

**Консультации:** [укажите время и место]

---

**Кафедра информационных технологий**

**2026 год**
