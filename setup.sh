#!/bin/bash

# Функция для вывода заголовков
print_header() {
    echo -e "\n${GREEN}===================$1===================${NC}"
}

# Функция для вывода шагов установки
print_step() {
    print_header "$1"
    echo -e "${YELLOW}$2${NC}"
}

# Обновление пакетов и установка tar
print_step "Обновление пакетов" "Обновляем список пакетов и устанавливаем tar..."
opkg update && opkg install tar

# Установка curl (если не установлен)
print_step "Установка curl" "Устанавливаем curl..."
opkg update && opkg install curl

# Установка unzip (если не установлен)
print_step "Установка unzip" "Устанавливаем unzip..."
opkg update && opkg install unzip

echo -e "\n${GREEN}Выберите версию для установки:${NC}"
echo -e "${BLUE}1. Версия 1${NC}"
echo -e "${BLUE}2. Версия 2${NC}"

read -p "Введите номер выбранной версии: " version_choice

case $version_choice in
    1)
        wget -O /root/version-1.sh https://raw.githubusercontent.com/Vancltkin/testneko/main/version-1.sh && chmod 0755 /root/version-1.sh && /root/version-1.sh
        ;;
    2)
        wget -O /root/version-2.sh https://raw.githubusercontent.com/Vancltkin/testneko/main/version-2.sh && chmod 0755 /root/version-2.sh && /root/version-2.sh
        ;;
    *)
        echo -e "${RED}Неверный выбор.${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Установка завершена успешно.${NC}"
