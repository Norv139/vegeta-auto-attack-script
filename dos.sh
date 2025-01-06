#!/bin/bash

method="GET"
iteration=5
query="" #?offset=$i&limit=100
add_new="false"

# Обработка аргументов
while getopts ":m:q:i:n" opt; do
    echo "item ${opt}"
  case $opt in
    
    m) method="$OPTARG" ;;
    q) query="$OPTARG" ;;
    i) iteration="$OPTARG" ;;
    n) add_new="true" ;;
    \?) 
  esac
done
echo "${method} ${iteration} ${host} ${add_new}"



os_name=$(uname -s)
# Linux
# Darwin
# CYGWIN - MINGW - wondows
# FreeBSD
# OpenBSD

os_arch=$(uname -m)
# x86 — 32-разрядная архитектура.
# x86_64 — 64-разрядная архитектура.
# arm — ARM архитектура.

DOWNLOAD_LINK=""

# определяем что скачивать
part_name_os=""
part_arch_os=""
part_exec_file="tar.gz"


# определяем систему
if [[ $os_name == "Darwin" ]]; then
    part_name_os="darwin"
elif [[ $os_name == "CYGWIN"* || $os_name == "MINGW"* ]]; then
    part_name_os="windows"
    part_exec_file="zip"
elif [[ $os_name == "FreeBSD" ]]; then
    part_name_os="freebsd"
elif [[ $os_name == "OpenBSD" ]]; then
    part_name_os="openbsd"
else # предположим, что это linux
    part_name_os="linux"
fi

# определяем архитектуру системы
if [[ $os_arch == "x86" ]]; then
    part_arch_os="386"
elif [[ $os_arch == "x86_64" ]]; then
    part_arch_os="amd64"
else #arm
    part_arch_os="arm64"
fi

# линка для скачивания
VERSION_APP="12.11.3"

MAIN_LINK="https://github.com/tsenart/vegeta/releases/download"

DOWNLOAD_LINK="${MAIN_LINK}/v${VERSION_APP}/vegeta_${VERSION_APP}_${part_name_os}_${part_arch_os}.${part_exec_file}"

if [ -e "vegeta" ]; then
    echo "vegeta exist"
else
    if [[ $part_exec_file == "zip"* ]]; then
        if [ -e "vegeta.zip" ]; then
            echo "vegeta.zip  exist"
        else
            curl -Lo vegeta.zip  $DOWNLOAD_LINK
        fi
        unzip vegeta.zip
    else 
        if [ -e "vegeta.tar.gz" ]; then
            echo "vegeta.tar.gz  exist"
        else
            curl -Lo vegeta.tar.gz $DOWNLOAD_LINK
        fi
        tar xf vegeta.tar.gz 
    fi
fi

file_hosts="hosts.txt"
file_targets="file_targets.txt"


if [[ -e "./${file_hosts}" ]]; then 
    echo "file_hosts exist"
else
    touch "./${file_hosts}"
fi
 
if [[ -e "./${file_hosts}" ]]; then

    declare -a array
    i=0

    while IFS= read -r line; do
        array[i++]="$line"
    done < "./${file_hosts}"

    if [[ $query != "" ]]; then
        array[i++]="$query"

        if [[ $add_new == "true" ]]; then
            echo "${query}" | tee -a "./${file_hosts}"
        fi
    fi

    for item in "${array[@]}"; do
        # переопределяем таргет
        if [ -e "./${file_targets}" ]; then
            echo -n > "./${file_targets}"
        else
            touch "./${file_targets}"
        fi

        for ((i=0; i<=12; i++)); do
            echo "${method} ${item}" |  tee -a "./${file_targets}" >> /dev/null &
        done

        for ((i=1; i<"${iteration}"; i++)); do
            echo "runing vegeta attack ${i}"
            cat "./${file_targets}" | ./vegeta attack  >> /dev/null &
            disown
        done
    done
fi
