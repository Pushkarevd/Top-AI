# Датасет №2 «Отток клиентов телеком-компании» (Telco Customer Churn)

## Паспорт датасета
|Параметр|	Значение|
|--------|----------|
|Название|	Telco Customer Churn|
|Источник	|Kaggle|
|Ссылка	|https://www.kaggle.com/datasets/rhonarosecortez/telco-customer-churn|
|Лицензия|	CC BY 4.0|
|Формат	|CSV|
|Объем	|7 043 записи|
|Размер файла|	~700 КБ|
|Дата актуализации|	Ноябрь 2024 г.|
|Язык	|Английский|

## Структура данных
|Поле|	Тип|	Описание|
|-----|-----|----------|
|customerID|	string|	Уникальный идентификатор клиента|
|gender|	string|Пол (Male/Female)|
|SeniorCitizen|	int	|Пенсионер (0/1)|
|Partner|	string|	Наличие партнера (Yes/No)|
|Dependents	|string|	Наличие иждивенцев (Yes/No)|
|tenure|	int	|Длительность обслуживания (месяцы)|
|PhoneService|	string|	Услуга телефонии (Yes/No)|
|MultipleLines|	string	|Несколько линии (Yes/No/No phone service)|
|InternetService|	string	|Тип интернет-услуги (DSL/Fiber optic/No)|
|OnlineSecurity	|string|	Онлайн-безопасность (Yes/No/No internet service)|
|OnlineBackup|	string|	Онлайн-бэкап (Yes/No/No internet service)|
|DeviceProtection|	string|	Защита устройств (Yes/No/No internet service)|
|TechSupport|	string	|Техподдержка (Yes/No/No internet service)|
|StreamingTV	|string	|Streaming TV (Yes/No/No internet service)|
|StreamingMovies|	string	|Streaming Movies (Yes/No/No internet service)|
|Contract	|string	|Тип контракта (Month-to-month/One year/Two year)|
|PaperlessBilling|	string	|Безбумажный биллинг (Yes/No)|
|PaymentMethod|	string|	Способ оплаты|
|MonthlyCharges	|float	|Ежемесячный платеж|
|TotalCharges	|float	|Общая сумма платежей|
|Churn|	string|	Отток (Yes/No) — целевая переменная|

## Описание и назначение

Датасет является альтернативным источником данных для проектной работы. Он позволяет:
  1. Реализовать задачу классификации — прогнозирование оттока клиентов.
  2. Продемонстрировать работу с реляционными данными — небольшие объемы, много категориальных признаков.
  3. Применить гибридное хранилище — PostgreSQL для структурированных данных + MinIO для сырых данных.

Особенности использования в проекте:
  - Подходит для команд, выбравших кейс «Прогнозирование оттока клиентов».
  - Может использоваться как дополнительный источник для демонстрации ETL-процессов.
  - Данные хорошо структурированы и не требуют сложной очистки.

## Учебный срез

        python
        def load_telco_data(spark):
            """
            Загрузка данных об оттоке клиентов телеком-компании.
            
            Параметры:
                spark (SparkSession): Активная сессия Spark.
            
            Возвращает:
                DataFrame: Данные о клиентах телеком-компании.
            """
            df = spark.read.csv(
                "/data/raw/Telco-Customer-Churn.csv",
                header=True,
                inferSchema=True
            )
            
            # Преобразование TotalCharges к числовому типу
            df = df.withColumn(
                "TotalCharges",
                F.col("TotalCharges").cast("double")
            )
            
            return df

## Варианты заданий
|Вариант	|Фокус EDA	|Целевая переменная|
|---------|-----------|------------------|
|0	|Распределение оттока по тарифам, демографические факторы	|Churn|
|1	|Корреляция tenure и Churn, анализ контрактов	|Churn|
|2|	Влияние услуг на отток, сегментация клиентов	|Churn|
|3	|Анализ платежного поведения, связь с оттоком|	Churn|

## Использование в лабораторных работах
|Лабораторная работа	|Использование датасета|
|---------------------|----------------------|
|Занятие 2.2|	Интеграция данных из открытых источников, ETL/ELT|
|Проектная работа	|Построение прогностической модели оттока|

## Ноутбуки-бейзлайны
Анализ данных телеком-компании (Telco Customer Churn)

        python
        from pyspark.sql import SparkSession
        from pyspark.sql import functions as F
        from pyspark.sql.types import DoubleType
        
        # ============================================================
        # 1. Инициализация Spark-сессии
        # ============================================================
        def create_spark_session():
            spark = SparkSession.builder \
                .appName("Telco_Churn_Analysis") \
                .master("spark://spark-master:7077") \
                .config("spark.executor.memory", "2g") \
                .getOrCreate()
            return spark
        
        # ============================================================
        # 2. Загрузка данных
        # ============================================================
        def load_telco_data(spark):
            df = spark.read.csv(
                "/data/raw/Telco-Customer-Churn.csv",
                header=True,
                inferSchema=True
            )
            
            df = df.withColumn("TotalCharges", F.col("TotalCharges").cast(DoubleType()))
            
            print(f"[INFO] Всего записей: {df.count()}")
            df.printSchema()
            df.show(5)
            
            return df
        
        # ============================================================
        # 3. Очистка данных
        # ============================================================
        def clean_telco_data(df):
            # 3.1. Удаление записей с NULL в TotalCharges
            df = df.filter(F.col("TotalCharges").isNotNull())
            
            # 3.2. Преобразование бинарных признаков в числовые
            binary_mapping = {"Yes": 1, "No": 0}
            for col in ["Churn", "PaperlessBilling"]:
                df = df.withColumn(col, F.when(F.col(col) == "Yes", 1).otherwise(0))
            
            print(f"[INFO] Записей после очистки: {df.count()}")
            
            return df
        
        # ============================================================
        # 4. Основной блок
        # ============================================================
        if __name__ == "__main__":
            spark = create_spark_session()
            df = load_telco_data(spark)
            df_clean = clean_telco_data(df)
            spark.stop()
