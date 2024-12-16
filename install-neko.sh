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

# Получение последней версии пакета с GitHub
get_latest_version() {
    print_info "Fetching latest version from GitHub..."
    API_URL="https://github.com/Thaolga/openwrt-nekobox/releases/latest"
    RELEASE_INFO=$(curl -s -L $API_URL)
    VERSION=$(echo "$RELEASE_INFO" | grep -o 'releases/tag/[0-9.]\+' | sed 's/releases\/tag\///')
    if [ -z "$VERSION" ]; then
        print_error "Unable to fetch the latest version. Please check the connection."
        exit 1
    fi
    print_success "Latest version: $VERSION"
}

# Скачивание пакета
download_package() {
    # Установка языка для скачивания соответствующего пакета
    if [ "$LANGUAGE" = "RU" ]; then
        LANGUAGE_SUFFIX="ru"
    elif [ "$LANGUAGE" = "CN" ]; then
        LANGUAGE_SUFFIX="cn"
    else
        LANGUAGE_SUFFIX="en"
    fi

    PACKAGE_URL="https://github.com/Thaolga/openwrt-nekobox/releases/download/$VERSION/luci-app-nekobox_${VERSION}-${LANGUAGE_SUFFIX}_all.ipk"
    print_info "Downloading package from $PACKAGE_URL..."
    if wget -O /tmp/luci-app-nekobox_${VERSION}-${LANGUAGE_SUFFIX}_all.ipk "$PACKAGE_URL"; then
        print_success "Package downloaded successfully"
    else
        print_error "Failed to download the package"
        exit 1
    fi
}

# Основной скрипт
get_latest_version
download_package

print_header "Installing package..."
if opkg install --force-depends /tmp/luci-app-nekobox_${VERSION}-${LANGUAGE_SUFFIX}_all.ipk; then
    print_success "Package installed successfully"
    rm -f /tmp/luci-app-nekobox_${VERSION}-${LANGUAGE_SUFFIX}_all.ipk
else
    print_error "Failed to install the package"
    exit 1
fi

print_info "Rebooting system in 3 seconds..."
sleep 3
reboot
