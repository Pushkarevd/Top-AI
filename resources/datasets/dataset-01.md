# Датасет №1: «Автомобили на рынке США» (US Used Cars Dataset)

## Паспорт датасета
|Параметр|	Значение|
|--------|---------|
|Название	|US Used Cars Dataset|
|Источник	|Kaggle|
|Ссылка|	https://www.kaggle.com/datasets/ananaymital/us-used-cars-dataset|
|Лицензия	|Apache 2.0 |
|Формат	|CSV|
|Объем	|~3 млн записей |
|Дата актуализации|	2021 г.|
|Язык|	Английский|

## Структура данных
|Поле	|Тип	|Описание|	Диапазон значений|
|----|-----|---------|--------------------|
|brand|	string	|Марка автомобиля|	~50 уникальных|
|model	|string|	Модель автомобиля|	~500 уникальных|
|year	|int|	Год выпуска|	1990-2021|
|price|	float|	Цена в USD|	500-200000|
|mileage|	float|	Пробег в милях|	0-300000|
|state	|string|	Штат продажи	|50 штатов|
|body_type|	string|	Тип кузова|	Sedan, SUV, Truck и др.|
|horsepower	|float|	Мощность двигателя (л.с.)	|50-800|
|wheel_system	|string|	Тип привода|	AWD/FWD/RWD/4WD|
|daysonmarket	|int|	Дней на рынке|	0-365|
|is_certified|	boolean	|Сертифицированный автомобиль|	TRUE/FALSE|
|is_cpo|	boolean|	CPO-сертификация|	TRUE/FALSE|
|is_oemcpo|	boolean	|OEM CPO-сертификация|	TRUE/FALSE|
|major_options|	string|	Список опций	|Строка с разделителями|
|maximum_seating|	int|	Количество посадочных мест|	2-15|
|vin|	string|	VIN-номер|	17 символов|

## Описание и назначение
Датасет используется как основной источник данных для проектной работы. Он позволяет:
  1. Продемонстрировать полный цикл работы инженера данных — от загрузки сырых данных до построения прогностической модели.
  2. Реализовать ETL/ELT-процессы — очистка, трансформация, обогащение данных.
  3. Применить технологии распределенного хранения — HDFS + Apache Iceberg.
  4. Построить прогностическую модель — прогнозирование цены автомобиля (регрессия).

Особенности использования в проекте:
  - Для локальной разработки используется сэмплирование (100 000 записей).
  - Полный датасет (3 млн записей) обрабатывается в кластерной среде.
  - Предусмотрены 4 варианта заданий с разными стратегиями партиционирования.

## Учебный срез

      #Загрузка данных с ограничением объема для локального выполнения
      def load_used_cars_data(spark, sample_size=100000):
          """
          Загрузка данных об автомобилях с возможностью сэмплирования.
          
          Параметры:
              spark (SparkSession): Активная сессия Spark.
              sample_size (int): Размер выборки (по умолчанию 100 000).
          
          Возвращает:
              DataFrame: Подвыборка данных об автомобилях.
          """
          df = spark.read.csv(
              "/data/raw/used_cars_data.csv",
              header=True,
              inferSchema=True
          )
          
          # Для локальной разработки используем сэмплирование
          if sample_size < df.count():
              df = df.sample(False, sample_size / df.count(), seed=42)
          
          return df

## Варианты заданий
|Вариант|	Стратегия партиционирования|	Фокус EDA|
|-------|----------------------------|-----------|
|0	| year, state|	Распределение по штатам, средняя цена по годам, корреляция year/mileage/price|
|1  | body_type, age|	Распределение по типам кузова, цена и возраст, доля сертифицированных|
|2	| wheel_system, is_any_cert	|Распределение по приводу, цена/пробег в разрезе привода, доля сертифицированных по штатам|
|3	| state, mileage_bucket|	Распределение по пробегу, цена в разрезе штата и пробега|

## Использование в лабораторных работах
|Лабораторная работа|	Использование датасета|
|------------------|------------------------|
|Занятие 3.3|	Загрузка в HDFS, создание Raw-таблицы, первичная очистка|
|Занятие 3.4|	Формирование детального слоя данных (DDS), обогащение справочниками|
|Занятие 3.6|	Оркестрация ETL-процессов с Airflow|
|Проектная работа|	Полный цикл обработки и построение ML-модели|

## Версии программного обеспечения и лицензии

Основные компоненты
|Компонент|	Версия|	Лицензия|	Источник|
|---------|-------|----------|---------|
|Apache Spark	|3.5.0	|Apache 2.0	|https://spark.apache.org|
|Apache Airflow	|2.8.0	|Apache 2.0	|https://airflow.apache.org|
|Apache Hadoop|	3.3.4|	Apache 2.0	|https://hadoop.apache.org|
|Apache Iceberg	|1.6.0|	Apache 2.0|	https://iceberg.apache.org|
|PostgreSQL	|15.3	|PostgreSQL License|	https://postgresql.org|
|ClickHouse	|23.6|	Apache 2.0|	https://clickhouse.com|
|MinIO|	RELEASE.2023-06-23|	AGPL-3.0|	https://min.io|
|OpenMetadata|	1.2.0|	Apache 2.0|	https://open-metadata.org|
|Python	|3.10.12|	Python Software Foundation	|https://python.org|

Python-библиотеки
|Библиотека|	Версия	|Лицензия	|Назначение|
|----------|---------|----------|----------|
|pyspark|	3.5.0	|Apache 2.0|	Распределенная обработка данных|
|pandas|	2.0.3|	BSD-3-Clause	|Анализ данных|
|numpy|	1.24.3	|BSD-3-Clause|	Численные вычисления|
|apache-airflow|	2.8.0|	Apache 2.0|	Оркестрация конвейеров|
|psycopg2-binary|	2.9.6|	LGPL-3.0	|Подключение к PostgreSQL|
|clickhouse-connect|	0.6.16|	Apache 2.0|	Подключение к ClickHouse|
|great-expectations|	0.17.7|	Apache 2.0	|Проверки качества данных|
|openmetadata-ingestion|	1.2.0	|Apache 2.0	|Интеграция с OpenMetadata|
|jupyter|	1.0.0	|BSD-3-Clause	|Интерактивная разработка|

## Docker Compose для развертывания инфраструктуры
docker-compose.yml

        yaml
        version: '3.8'
        
        services:
          # ============================================================
          # Apache Hadoop + Spark Cluster
          # ============================================================
          namenode:
            image: bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8
            container_name: namenode
            restart: always
            ports:
              - "9870:9870"
              - "9000:9000"
            volumes:
              - hadoop_namenode:/hadoop/dfs/name
            environment:
              - CLUSTER_NAME=test
            env_file:
              - ./hadoop.env
        
          datanode1:
            image: bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8
            container_name: datanode1
            restart: always
            volumes:
              - hadoop_datanode1:/hadoop/dfs/data
            environment:
              SERVICE_PRECONDITION: "namenode:9870"
            env_file:
              - ./hadoop.env
        
          datanode2:
            image: bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8
            container_name: datanode2
            restart: always
            volumes:
              - hadoop_datanode2:/hadoop/dfs/data
            environment:
              SERVICE_PRECONDITION: "namenode:9870"
            env_file:
              - ./hadoop.env
        
          datanode3:
            image: bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8
            container_name: datanode3
            restart: always
            volumes:
              - hadoop_datanode3:/hadoop/dfs/data
            environment:
              SERVICE_PRECONDITION: "namenode:9870"
            env_file:
              - ./hadoop.env
        
          resourcemanager:
            image: bde2020/hadoop-resourcemanager:2.0.0-hadoop3.2.1-java8
            container_name: resourcemanager
            restart: always
            environment:
              SERVICE_PRECONDITION: "namenode:9000 namenode:9870 datanode:9864"
            env_file:
              - ./hadoop.env
        
          nodemanager:
            image: bde2020/hadoop-nodemanager:2.0.0-hadoop3.2.1-java8
            container_name: nodemanager
            restart: always
            environment:
              SERVICE_PRECONDITION: "namenode:9000 namenode:9870 datanode:9864 resourcemanager:8088"
            env_file:
              - ./hadoop.env
        
          historyserver:
            image: bde2020/hadoop-historyserver:2.0.0-hadoop3.2.1-java8
            container_name: historyserver
            restart: always
            environment:
              SERVICE_PRECONDITION: "namenode:9000 namenode:9870 datanode:9864 resourcemanager:8088"
            volumes:
              - hadoop_historyserver:/hadoop/yarn/timeline
            env_file:
              - ./hadoop.env
        
          spark-master:
            image: bitnami/spark:3.5.0
            container_name: spark-master
            hostname: spark-master
            environment:
              - SPARK_MODE=master
              - SPARK_MASTER_HOST=spark-master
              - SPARK_MASTER_PORT=7077
              - SPARK_RPC_AUTHENTICATION_ENABLED=no
              - SPARK_RPC_ENCRYPTION_ENABLED=no
              - SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED=no
              - SPARK_SSL_ENABLED=no
            ports:
              - "8080:8080"
              - "7077:7077"
            volumes:
              - ./data:/data
              - ./notebooks:/notebooks
              - ./spark-apps:/spark-apps
            depends_on:
              - namenode
              - datanode1
              - datanode2
              - datanode3
        
          spark-worker:
            image: bitnami/spark:3.5.0
            container_name: spark-worker
            hostname: spark-worker
            environment:
              - SPARK_MODE=worker
              - SPARK_MASTER_URL=spark://spark-master:7077
              - SPARK_WORKER_MEMORY=4G
              - SPARK_WORKER_CORES=2
            ports:
              - "8081:8081"
            volumes:
              - ./data:/data
              - ./spark-apps:/spark-apps
            depends_on:
              - spark-master
        
          # ============================================================
          # Apache Airflow
          # ============================================================
          postgres:
            image: postgres:15.3
            container_name: postgres
            hostname: postgres
            environment:
              - POSTGRES_USER=airflow
              - POSTGRES_PASSWORD=airflow
              - POSTGRES_DB=airflow
            ports:
              - "5432:5432"
            volumes:
              - ./postgres-data:/var/lib/postgresql/data
        
          airflow-webserver:
            image: apache/airflow:2.8.0
            container_name: airflow-webserver
            hostname: airflow-webserver
            environment:
              - AIRFLOW__CORE__EXECUTOR=LocalExecutor
              - AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres:5432/airflow
              - AIRFLOW__WEBSERVER__RBAC=True
              - AIRFLOW__WEBSERVER__SECRET_KEY=your-secret-key
            ports:
              - "8082:8080"
            volumes:
              - ./airflow/dags:/opt/airflow/dags
              - ./airflow/logs:/opt/airflow/logs
              - ./airflow/plugins:/opt/airflow/plugins
            depends_on:
              - postgres
            command: webserver
        
          airflow-scheduler:
            image: apache/airflow:2.8.0
            container_name: airflow-scheduler
            hostname: airflow-scheduler
            environment:
              - AIRFLOW__CORE__EXECUTOR=LocalExecutor
              - AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres:5432/airflow
            volumes:
              - ./airflow/dags:/opt/airflow/dags
              - ./airflow/logs:/opt/airflow/logs
              - ./airflow/plugins:/opt/airflow/plugins
            depends_on:
              - postgres
              - airflow-webserver
            command: scheduler
        
          # ============================================================
          # ClickHouse (OLAP-хранилище)
          # ============================================================
          clickhouse:
            image: clickhouse/clickhouse-server:23.6
            container_name: clickhouse
            hostname: clickhouse
            ports:
              - "8123:8123"
              - "9000:9000"
            volumes:
              - ./clickhouse-data:/var/lib/clickhouse
        
          # ============================================================
          # MinIO (озеро данных)
          # ============================================================
          minio:
            image: minio/minio:RELEASE.2023-06-23
            container_name: minio
            hostname: minio
            environment:
              - MINIO_ROOT_USER=minioadmin
              - MINIO_ROOT_PASSWORD=minioadmin
            ports:
              - "9001:9000"
              - "9002:9001"
            volumes:
              - ./minio-data:/data
            command: server /data --console-address ":9001"
        
          # ============================================================
          # OpenMetadata (управление метаданными)
          # ============================================================
          openmetadata-server:
            image: openmetadata/server:1.2.0
            container_name: openmetadata-server
            hostname: openmetadata-server
            environment:
              - OM_AUTHORITY=openmetadata-server
              - OM_PORT=8585
              - OM_HOST=openmetadata-server
              - OPENMETADATA_SERVER_PORT=8585
            ports:
              - "8585:8585"
            depends_on:
              - postgres
        
        volumes:
          hadoop_namenode:
          hadoop_datanode1:
          hadoop_datanode2:
          hadoop_datanode3:
          hadoop_historyserver:
          postgres-data:
          clickhouse-data:
          minio-data:

hadoop.env (конфигурация Hadoop)

        text
        CORE_CONF_fs_defaultFS=hdfs://namenode:9000
        CORE_CONF_hadoop_http_staticuser_user=root
        CORE_CONF_hadoop_proxyuser_hue_hosts=*
        CORE_CONF_hadoop_proxyuser_hue_groups=*
        CORE_CONF_io_compression_codecs=org.apache.hadoop.io.compress.SnappyCodec
        
        HDFS_CONF_dfs_webhdfs_enabled=true
        HDFS_CONF_dfs_permissions_enabled=false
        HDFS_CONF_dfs_namenode_datanode_registration_ip___hostname___check=false
        
        YARN_CONF_yarn_log___aggregation___enable=true
        YARN_CONF_yarn_log_server_url=http://historyserver:8188/applicationhistory/logs/
        YARN_CONF_yarn_resourcemanager_recovery_enabled=true
        YARN_CONF_yarn_resourcemanager_store_class=org.apache.hadoop.yarn.server.resourcemanager.recovery.FileSystemRMStateStore
        YARN_CONF_yarn_resourcemanager_scheduler_class=org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler
        YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___mb=8192
        YARN_CONF_yarn_scheduler_capacity_root_default_maximum___allocation___vcores=4
        YARN_CONF_yarn_resourcemanager_fs_state___store_uri=/rmstate
        YARN_CONF_yarn_resourcemanager_system___metrics___publisher_enabled=true
        YARN_CONF_yarn_resourcemanager_hostname=resourcemanager
        YARN_CONF_yarn_resourcemanager_address=resourcemanager:8032
        YARN_CONF_yarn_resourcemanager_scheduler_address=resourcemanager:8030
        YARN_CONF_yarn_resourcemanager_resource__tracker_address=resourcemanager:8031
        YARN_CONF_yarn_timeline___service_enabled=true
        YARN_CONF_yarn_timeline___service_generic___application___history_enabled=true
        YARN_CONF_yarn_timeline___service_hostname=historyserver
        YARN_CONF_mapreduce_map_output_compress=true
        YARN_CONF_mapred_map_output_compress_codec=org.apache.hadoop.io.compress.SnappyCodec
        
        MAPRED_CONF_mapreduce_framework_name=yarn
        MAPRED_CONF_mapred_child_java_opts=-Xmx4096m
        MAPRED_CONF_mapreduce_map_memory_mb=4096
        MAPRED_CONF_mapreduce_reduce_memory_mb=8192

## Ноутбуки-бейзлайны
Анализ данных об автомобилях (PySpark)
        
        python
        from pyspark.sql import SparkSession
        from pyspark.sql import functions as F
        from pyspark.sql.types import IntegerType, DoubleType, BooleanType
        import os
        
        # ============================================================
        # 1. Инициализация Spark-сессии
        # ============================================================
        def create_spark_session():
            """
            Создает Spark-сессию с настройками для проектной работы.
            """
            spark = SparkSession.builder \
                .appName("Project_Data_Preparation") \
                .master("spark://spark-master:7077") \
                .config("spark.executor.memory", "4g") \
                .config("spark.executor.cores", "2") \
                .config("spark.driver.memory", "2g") \
                .getOrCreate()
            
            return spark
        
        # ============================================================
        # 2. Загрузка данных
        # ============================================================
        def load_used_cars_data(spark):
            """
            Загрузка данных об автомобилях.
            """
            df = spark.read.csv(
                "/data/raw/used_cars_data.csv",
                header=True,
                inferSchema=True
            )
            
            print(f"[INFO] Всего записей: {df.count()}")
            print(f"[INFO] Количество колонок: {len(df.columns)}")
            df.printSchema()
            df.show(5)
            
            return df
        
        # ============================================================
        # 3. Очистка данных (BD-2.2)
        # ============================================================
        def clean_data(df):
            """
            Выполняет очистку данных об автомобилях.
            """
            # 3.1. Приведение типов
            df = df.withColumn("year", F.col("year").cast(IntegerType())) \
                   .withColumn("price", F.col("price").cast(DoubleType())) \
                   .withColumn("mileage", F.col("mileage").cast(DoubleType())) \
                   .withColumn("horsepower", F.col("horsepower").cast(DoubleType())) \
                   .withColumn("daysonmarket", F.col("daysonmarket").cast(IntegerType())) \
                   .withColumn("maximum_seating", F.col("maximum_seating").cast(IntegerType()))
            
            # 3.2. Удаление столбцов с >50% пропусков
            columns_to_drop = ["fleet", "has_accidents", "frame_damaged", "salvage"]
            df = df.drop(*columns_to_drop)
            
            # 3.3. Фильтрация по VIN
            df = df.filter(F.col("vin").rlike(r"^[A-Z0-9]{17}$"))
            
            # 3.4. Удаление дубликатов
            df = df.dropDuplicates(["vin"])
            
            # 3.5. Обработка пропусков
            df = df.fillna({
                "body_type": "Unknown",
                "wheel_system": "AWD",
                "horsepower": 0.0,
                "maximum_seating": 0
            })
            
            # 3.6. Ограничение выбросов
            df = df.filter(
                (F.col("horsepower") < 400) &
                (F.col("mileage") <= 200000) &
                (F.col("price") <= 60000) &
                (F.col("maximum_seating") < 20)
            )
            
            # 3.7. Формирование производных признаков
            df = df.withColumn(
                "is_any_cert",
                F.col("is_certified") | F.col("is_cpo") | F.col("is_oemcpo")
            ).withColumn(
                "age",
                2024 - F.col("year")
            )
            
            print(f"[INFO] Записей после очистки: {df.count()}")
            
            return df
        
        # ============================================================
        # 4. Проверка качества данных (BD-2.2)
        # ============================================================
        def data_quality_report(df):
            """
            Генерирует отчет о качестве данных.
            """
            total_rows = df.count()
            report = {"total_rows": total_rows}
            
            # Проверка полноты ключевых полей
            for col in ["vin", "year", "state"]:
                null_count = df.filter(F.col(col).isNull()).count()
                report[f"{col}_completeness"] = {
                    "null_count": null_count,
                    "percentage": round(null_count / total_rows * 100, 2)
                }
            
            # Проверка уникальности VIN
            unique_vin = df.select("vin").distinct().count()
            report["vin_uniqueness"] = {
                "unique_count": unique_vin,
                "percentage": round(unique_vin / total_rows * 100, 2)
            }
            
            return report
        
        # ============================================================
        # 5. Основной блок
        # ============================================================
        if __name__ == "__main__":
            spark = create_spark_session()
            
            df = load_used_cars_data(spark)
            df_clean = clean_data(df)
            
            # Отчет о качестве данных
            report = data_quality_report(df_clean)
            print("\n=== ОТЧЕТ О КАЧЕСТВЕ ДАННЫХ ===")
            for key, value in report.items():
                print(f"{key}: {value}")
            
            # Сохранение данных
            df_clean.write \
                .mode("overwrite") \
                .partitionBy("year", "state") \
                .parquet("/data/clean/cars_clean.parquet")
            
            spark.stop()



