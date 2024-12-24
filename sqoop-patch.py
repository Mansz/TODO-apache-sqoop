# Dokumentasi dan Skrip untuk Proses Import dan Export Data dengan Sqoop

## 1. Prasyarat
- **VM CentOS 7** sudah disiapkan.
- **MySQL Server** sudah dikonfigurasi dan berjalan.
- **Sqoop** sudah terinstal pada VM.
- Database MySQL memiliki tabel input dan output dengan skema yang sama.

## 2. Langkah-Langkah Proses

### A. Membuat Data Dummy pada MySQL
1. Buat tabel input di MySQL:

```sql
CREATE TABLE input_table (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  age INT,
  city VARCHAR(100)
);
```

2. Isi tabel dengan data dummy menggunakan script berikut:

```bash
#!/bin/bash

MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_DB="sample_db"
MYSQL_USER="root"
MYSQL_PASS=""
MYSQL_TABLE_INPUT="input_table"

mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_DB <<EOF
INSERT INTO $MYSQL_TABLE_INPUT (name, age, city)
SELECT CONCAT('User', id), FLOOR(20 + (RAND() * 30)), CONCAT('City', FLOOR(1 + (RAND() * 10)))
FROM (SELECT NULL id UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL) t
CROSS JOIN (SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL) t2;
EOF
```

Script ini akan menghasilkan sekitar 100 baris data dummy di tabel `input_table`.

### B. Import Data dari MySQL ke HDFS atau Hive
1. Jalankan perintah berikut di VM CentOS 7 untuk mengimpor data:

```bash
sqoop import \
  --connect jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB \
  --username $MYSQL_USER \
  --password $MYSQL_PASS \
  --table $MYSQL_TABLE_INPUT \
  --target-dir /user/hdfs/sample_data \
  --num-mappers 1 \
  --fields-terminated-by ','
```

### C. Export Data dari HDFS ke MySQL
1. Pastikan tabel MySQL tujuan sudah tersedia:

```sql
CREATE TABLE output_table (
  id INT PRIMARY KEY,
  name VARCHAR(100),
  age INT,
  city VARCHAR(100)
);
```

2. Jalankan perintah berikut untuk mengekspor data:

```bash
sqoop export \
  --connect jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB \
  --username $MYSQL_USER \
  --password $MYSQL_PASS \
  --table output_table \
  --export-dir /user/hdfs/sample_data \
  --input-fields-terminated-by ','
```

## 3. Skrip Lengkap

Buat file `sqoop_process.sh` dengan isi berikut:

```bash
#!/bin/bash

# Variabel
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_DB="sample_db"
MYSQL_USER="root"
MYSQL_PASS=""
MYSQL_TABLE_INPUT="input_table"
MYSQL_TABLE_OUTPUT="output_table"
HDFS_DIR="/user/hdfs/sample_data"

# Membuat Data Dummy
mysql -h $MYSQL_HOST -P $MYSQL_PORT -u $MYSQL_USER -p$MYSQL_PASS $MYSQL_DB <<EOF
INSERT INTO $MYSQL_TABLE_INPUT (name, age, city)
SELECT CONCAT('User', id), FLOOR(20 + (RAND() * 30)), CONCAT('City', FLOOR(1 + (RAND() * 10)))
FROM (SELECT NULL id UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL) t
CROSS JOIN (SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL UNION ALL SELECT NULL) t2;
EOF

# Import Data dari MySQL ke HDFS
sqoop import \
  --connect jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB \
  --username $MYSQL_USER \
  --password $MYSQL_PASS \
  --table $MYSQL_TABLE_INPUT \
  --target-dir $HDFS_DIR \
  --num-mappers 1 \
  --fields-terminated-by ','

# Export Data dari HDFS ke MySQL
sqoop export \
  --connect jdbc:mysql://$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB \
  --username $MYSQL_USER \
  --password $MYSQL_PASS \
  --table $MYSQL_TABLE_OUTPUT \
  --export-dir $HDFS_DIR \
  --input-fields-terminated-by ','
```

## 4. Cara Menjalankan
1. Simpan skrip di VM CentOS 7.
2. Berikan izin eksekusi:

```bash
chmod +x sqoop_process.sh
```

3. Jalankan skrip:

```bash
./sqoop_process.sh
```

## 5. Hasil
- Data dummy berhasil dibuat di tabel MySQL input.
- Data dari tabel MySQL input berhasil diimpor ke HDFS.
- Data dari HDFS berhasil diekspor ke tabel MySQL output.
