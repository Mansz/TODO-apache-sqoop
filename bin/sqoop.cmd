@echo off
:: Licensed to the Apache Software Foundation (ASF) under one or more
:: contributor license agreements.  See the NOTICE file distributed with
:: this work for additional information regarding copyright ownership.
:: The ASF licenses this file to You under the Apache License, Version 2.0
:: (the "License"); you may not use this file except in compliance with
:: the License.  You may obtain a copy of the License at
::
::
::     http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

@echo off
setlocal enabledelayedexp
ansion

:: Mendapatkan jalur lengkap file batch yang sedang dijalankan
set prgm=%~f0
set bin=%~dp0

:: Menghapus backslash di akhir direktori, jika ada
if "%bin:~-1%" == "\" (
  set bin=%bin:~0,-1%
)

:: Periksa apakah file konfigurasi Sqoop ada
if exist "%bin%\configure-sqoop.cmd" (
  echo Menjalankan konfigurasi Sqoop...
  call "%bin%\configure-sqoop.cmd" "%bin%"
) else (
  echo Konfigurasi Sqoop tidak ditemukan: "%bin%\configure-sqoop.cmd"
  exit /b 1
)

:: Periksa apakah variabel HADOOP_HOME sudah diatur
if not defined HADOOP_HOME (
  echo [ERROR] Variabel lingkungan HADOOP_HOME belum diatur.
  exit /b 1
)

:: Periksa apakah file hadoop dapat ditemukan
if not exist "%HADOOP_HOME%\bin\hadoop" (
  echo [ERROR] File Hadoop tidak ditemukan di "%HADOOP_HOME%\bin\hadoop".
  exit /b 1
)

:: Jalankan Sqoop melalui Hadoop
echo Menjalankan Sqoop...
call "%HADOOP_HOME%\bin\hadoop" org.apache.sqoop.Sqoop %*

:: Mengakhiri blok setlocal
endlocal

