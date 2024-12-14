#!/bin/bash

# Обновление пакетов и установка tar
echo "Updating package list and installing tar..."
opkg update && opkg install tar

# Установка curl (если не установлен)
echo "Installing curl..."
opkg update && opkg install curl

# Загрузка и выполнение нового скрипта
echo "Downloading and executing the new script..."
wget -O /root/net.sh https://raw.githubusercontent.com/Vancltkin/testneko/main/net.sh && chmod 0755 /root/net.sh && /root/net.sh
