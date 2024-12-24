#!/bin/bash

# Variabel
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
MYSQL_DB="projectt"
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
