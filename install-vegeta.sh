#!/bin/bash

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