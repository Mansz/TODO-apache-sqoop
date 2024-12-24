#!/bin/bash
#
# Copyright 2011 The Apache Software Foundation
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script stops a metastore instance.
# Usage: stop-metastore.sh -p pidfilename

#!/bin/bash

set -e
set -o pipefail

prgm=$0
bin=$(dirname "$prgm")

# Parsing arguments
while [ ! -z "$1" ]; do
  case "$1" in
    -p)
      shift
      pidfilename=$1
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

# Validasi argumen
if [ -z "${pidfilename}" ]; then
  echo "Error: Missing argument: -p pidfilename"
  exit 1
fi

# Tambahkan trailing slash ke bin jika diperlukan
if [ -n "$bin" ]; then
  bin="$bin/"
fi

# Shutdown *metastore* yang sedang berjalan
echo "Attempting to shut down Sqoop metastore..."
HADOOP_ROOT_LOGGER=${HADOOP_ROOT_LOGGER:-ERROR,console} \
  "${bin}sqoop" metastore --shutdown 2>&1 >/dev/null

ret=$?
if [ "$ret" -eq 0 ]; then
  echo "Sqoop metastore shut down successfully."
else
  echo "Warning: Could not shut down Sqoop metastore. It may not be running."
fi

# Menghapus file PID
if [ -f "$pidfilename" ]; then
  echo "Removing PID file: $pidfilename"
  rm -f "$pidfilename"
else
  echo "Warning: PID file '$pidfilename' not found. Nothing to remove."
fi

echo "Sqoop metastore shutdown process completed."

