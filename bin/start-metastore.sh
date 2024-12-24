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
# This script starts a metastore instance.
# Usage: start-metastore.sh -p pidfilename -l logdir

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
    -l)
      shift
      logdir=$1
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
  shift
done

# Validasi argumen
if [ -z "${pidfilename}" ]; then
  echo "Error: Missing argument: -p pidfilename"
  exit 1
fi

if [ -z "${logdir}" ]; then
  echo "Error: Missing argument: -l logdir"
  exit 1
fi

if [ ! -d "${logdir}" ]; then
  echo "Warning: Log directory '${logdir}' does not exist. Logging may fail."
fi

# Fungsi: Periksa apakah PID masih aktif
pid_file_alive() {
  local pidfile=$1
  local programname=$2
  local checkpid=$(cat "$pidfile" 2>/dev/null || echo "")
  if [ -n "$checkpid" ] && ps -p "$checkpid" | grep -q "$programname"; then
    return 0
  else
    return 1
  fi
}

# Fungsi: Gagal jika PID sudah ada
fail_if_pid_exists() {
  local pidfile=$1
  local programname=$2
  if pid_file_alive "$pidfile" "$programname"; then
    echo "Error: PID file '$pidfile' already exists; '$programname' is already running."
    exit 1
  fi
}

# Validasi PID file
if [ -f "$pidfilename" ]; then
  fail_if_pid_exists "$pidfilename" "sqoop"
  echo "Removing stale PID file: $pidfilename"
  rm -f "$pidfilename"
fi

# Menulis PID sementara
pid=$$
echo "$pid" > "$pidfilename.$pid"
if [ ! -f "$pidfilename.$pid" ]; then
  echo "Error: Could not create temporary PID file '$pidfilename.$pid'."
  exit 1
fi

# Atomic: Membuat hardlink ke PID utama
ln -f "$pidfilename.$pid" "$pidfilename"

# Validasi PID file utama
if [ ! -f "$pidfilename" ] || [ "$(cat "$pidfilename")" != "$pid" ]; then
  echo "Error: Failed to create atomic PID file '$pidfilename'."
  rm -f "$pidfilename.$pid"
  exit 1
fi

# Menentukan log file
user=$(id -un)
host=$(hostname)
logfile="${logdir}/sqoop-metastore-${user}-${host}.log"

touch "$logfile" >/dev/null 2>&1 || {
  echo "Warning: Cannot write to log directory. Logging disabled."
  logfile="/dev/null"
}

# Memulai Sqoop metastore
if [ -n "$bin" ]; then
  bin="$bin/"
fi

nohup "${bin}sqoop" metastore >"$logfile" 2>&1 &
ret=$?
realpid=$!

if [ "$ret" -ne 0 ]; then
  echo "Error: Failed to start Sqoop metastore."
  rm -f "$pidfilename" "$pidfilename.$pid"
  exit "$ret"
fi

# Perbarui PID file dengan real PID
echo "$realpid" >"$pidfilename"

# Hapus PID sementara
rm -f "$pidfilename.$pid"

echo "Sqoop metastore started successfully with PID $realpid."



