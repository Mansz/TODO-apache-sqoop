#!/bin/bash
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
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
#
# rat-violations.sh
#   Given an audit report generated by Apache RAT, determine which violations
#   may be genuine.
#
# Arguments:
#   rat-violations.sh <audit-log-file> <basedir>
#
# audit-log-file should the filename containing the output of RAT.
# basedir should be the base directory where the audit was run.

auditlog=$1
basedir=$2

if [ ! -f "${auditlog}" ]; then
  echo "Could not read audit log: ${auditlog}"
  exit 1
fi

auditbase=`dirname $auditlog`
filtered=${auditbase}/filtered-release-audit.log

sed -i -e "s|${basedir}||" ${auditlog}

# Exclude paths that don't count.
# Anything in /docs is auto-generated.
# Anything in /testdata is a file that is supposed to represent exact output.
grep '!?????' ${auditlog} \
    | grep -v ' \/docs\/' \
    | grep -v ' \/target\/' \
    | grep -v ' \/testdata\/' \
    | grep -v ' \/gradle\/' \
    | grep -v ' \/gradlew' \
    | grep -v ' \/gradlew.bat' \
    > ${filtered}

# Check: did we find any violations after filtering?
grep '!?????' ${filtered}
status=$?

if [ "$status" == "0" ]; then
  # We found something that looks genuine.
  echo Possible violations found.
  echo See ${filtered}
  exit 1
fi




