#!/bin/sh

# Цвета для выделения текста
YELLOW="\033[1;33m"
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
RESET="\033[0m"

# Переменные для перевода
LANGUAGE="EN"
MSG_HEADER=""
MSG_SUCCESS=""
MSG_ERROR=""
MSG_INFO=""

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

# Локализация
set_language() {
    case $LANGUAGE in
        RU)
            MSG_HEADER="Выберите язык: 1) Русский 2) Английский 3) Китайский"
            MSG_SUCCESS="успешно"
            MSG_ERROR="Ошибка"
            MSG_INFO="Информация"
            ;;
        CN)
            MSG_HEADER="选择语言：1）俄语 2）英语 3）中文"
            MSG_SUCCESS="成功"
            MSG_ERROR="错误"
            MSG_INFO="信息"
            ;;
        *)
            MSG_HEADER="Select Language: 1) Russian 2) English 3) Chinese"
            MSG_SUCCESS="Success"
            MSG_ERROR="Error"
            MSG_INFO="Info"
            ;;
    esac
}

# Выбор языка
print_header "Language Selection / Выбор языка / 选择语言"
echo -e "1) Русский\n2) English\n3) 中文"
read -p "Ваш выбор / Your choice / 选择: " lang_choice
case $lang_choice in
    1) LANGUAGE="RU" ;;
    2) LANGUAGE="EN" ;;
    3) LANGUAGE="CN" ;;
    *) LANGUAGE="EN" ;;  # По умолчанию EN
esac

set_language

# Функция для установки luci-app-nekobox
install_luci_app_nekobox() {
    print_header "Обновление списка пакетов"
    if ! opkg update; then
        print_error "Failed to update package list"
        return 1
    fi

    print_header "Installing dependencies"
    deps=("curl" "luci-compat" "luci-lib-jsonc")
    for dep in "${deps[@]}"; do
        if ! opkg install "$dep"; then
            print_error "Failed to install dependency: $dep"
            return 1
        fi
    done

    print_header "Fetching latest version..."
    HTML=$(curl -sL https://github.com/Thaolga/openwrt-nekobox/releases/latest)
    URL=$(echo "$HTML" | grep -o 'href="[^"]*luci-app-nekobox_[^"]*_en_all\.ipk' | sed 's/href="//;s/"//' | head -n 1)

    if [ -z "$URL" ]; then
        print_error "Failed to find latest version"
        return 1
    fi

    FULL_URL="https://github.com$URL"
    print_info "Found latest version: $FULL_URL"

    print_header "Downloading package..."
    wget -O /tmp/luci-app-nekobox_latest_en.ipk "$FULL_URL"

    print_header "Installing package..."
    if ! opkg install --force-depends /tmp/luci-app-nekobox_latest_en.ipk; then
        print_error "Failed to install package"
        return 1
    fi

    print_success "Package installed successfully"
    rm -f /tmp/luci-app-nekobox_latest_en.ipk

    print_info "Rebooting system in 3 seconds..."
    sleep 3
    reboot
}

# Основной скрипт
print_header "Обновление списка пакетов"
if opkg update; then
    print_success "Список пакетов успешно обновлён"
else
    print_error "Ошибка при обновлении списка пакетов"
    exit 1
fi

install_luci_app_nekobox

print_header "Перезагрузка устройства"
if reboot; then
    print_success "Устройство перезагружается"
else
    print_error "Ошибка при перезагрузке устройства"
    exit 1
fi
