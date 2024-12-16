#!/bin/sh

# Цвета для выделения текста
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Функция для отображения заголовков
print_header() {
    echo -e "${YELLOW}=== $1 ===${RESET}"
}

# Функция для успешных сообщений
print_success() {
    echo -e "${GREEN}[✔] $1${RESET}"
}

# Функция для ошибок
print_error() {
    echo -e "${RED}[✘] $1${RESET}"
}

# Функция для обычных сообщений
print_info() {
    echo -e "${BLUE}[ℹ] $1${RESET}"
}

# Основной скрипт
print_header "Обновление списка пакетов"
if opkg update; then
    print_success "Список пакетов успешно обновлён"
else
    print_error "Ошибка при обновлении списка пакетов"
    exit 1
fi

print_header "Установка необходимых зависимостей"
if opkg install curl; then
    print_success "curl успешно установлен"
else
    print_error "Ошибка при установке curl"
    exit 1
fi

if opkg install luci-compat luci-lib-jsonc; then
    print_success "Зависимости luci-compat и luci-lib-jsonc успешно установлены"
else
    print_error "Ошибка при установке зависимостей"
    exit 1
fi

print_header "Загрузка пакета luci-app-nekobox"
if wget -O /tmp/luci-app-nekobox_1.5.9-en_all.ipk https://github.com/Thaolga/openwrt-nekobox/releases/download/1.5.9/luci-app-nekobox_1.5.9-en_all.ipk; then
    print_success "Пакет luci-app-nekobox успешно загружен"
else
    print_error "Ошибка при загрузке пакета luci-app-nekobox"
    exit 1
fi

print_header "Установка пакета luci-app-nekobox"
if opkg install --force-depends /tmp/luci-app-nekobox_1.5.9-en_all.ipk; then
    print_success "Пакет luci-app-nekobox успешно установлен"
else
    print_error "Ошибка при установке пакета luci-app-nekobox"
    exit 1
fi

print_header "Удаление временного файла"
if rm -f /tmp/luci-app-nekobox_1.5.9-en_all.ipk; then
    print_success "Временный файл успешно удалён"
else
    print_error "Ошибка при удалении временного файла"
    exit 1
fi

print_header "Перезагрузка устройства"
if reboot; then
    print_success "Устройство перезагружается"
else
    print_error "Ошибка при перезагрузке устройства"
    exit 1
fi
