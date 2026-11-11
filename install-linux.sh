#!/bin/bash

# Vivaldi Auto-Patch Installer for Linux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPT_DIR" || exit 1

INSTALL_DIR="$HOME/.local/share/vivaldi-patch"

echo "--- Встановлення автоматичного патчера Vivaldi ---"

# 1. Створення папки в домівці
mkdir -p "$INSTALL_DIR"
echo "Створено директорію: $INSTALL_DIR"

# 2. Копіювання файлів
if [ -f "dist/custom.js" ]; then
    cp "dist/custom.js" "$INSTALL_DIR/"
    echo "Актуальний custom.js скопійовано у $INSTALL_DIR"
else
    echo "Помилка: dist/custom.js не знайдено! Спочатку запустіть 'npm run build'."
    exit 1
fi

if [ -f "dist/svb-folder.html" ]; then
    cp "dist/svb-folder.html" "$INSTALL_DIR/"
    echo "Актуальний svb-folder.html скопійовано у $INSTALL_DIR"
fi

# Створюємо автономний скрипт патчування в папці встановлення
cat << 'EOF' > "$INSTALL_DIR/patch.sh"
#!/bin/bash
# Цей скрипт автоматично підключає мод до Vivaldi
WINDOW_HTML="/opt/vivaldi/resources/vivaldi/window.html"
CUSTOM_JS_DEST="/opt/vivaldi/resources/vivaldi/custom.js"
FOLDER_HTML_DEST="/opt/vivaldi/resources/vivaldi/svb-folder.html"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SCRIPT_PATH="$DIR/custom.js"
FOLDER_HTML_PATH="$DIR/svb-folder.html"

if [ ! -f "$WINDOW_HTML" ]; then exit 0; fi

# Перевіряємо чи потрібно оновити файл custom.js
if [ ! -f "$CUSTOM_JS_DEST" ] || ! cmp -s "$SCRIPT_PATH" "$CUSTOM_JS_DEST"; then
    cp "$SCRIPT_PATH" "$CUSTOM_JS_DEST"
    echo "Файл custom.js оновлено у папці Vivaldi."
fi

if [ -f "$FOLDER_HTML_PATH" ]; then
    if [ ! -f "$FOLDER_HTML_DEST" ] || ! cmp -s "$FOLDER_HTML_PATH" "$FOLDER_HTML_DEST"; then
        cp "$FOLDER_HTML_PATH" "$FOLDER_HTML_DEST"
        echo "Файл svb-folder.html оновлено у папці Vivaldi."
    fi
fi

# Патчимо window.html якщо підключення відсутнє
if ! grep -q "custom.js" "$WINDOW_HTML"; then
    sed -i 's/<\/body>/<script src="custom.js"><\/script><\/body>/' "$WINDOW_HTML"
    echo "window.html патчовано: додано підключення custom.js"
fi
EOF

chmod +x "$INSTALL_DIR/patch.sh"
echo "Скрипт патчування створено/оновлено: $INSTALL_DIR/patch.sh"

# 3. Негайне застосування патча (потрібні права root для запису в /opt/vivaldi)
if [ "$EUID" -ne 0 ]; then
    echo "Запитую права sudo для застосування змін..."
    sudo "$INSTALL_DIR/patch.sh"
else
    "$INSTALL_DIR/patch.sh"
fi

echo "--- Встановлення завершено успішно! ---"
echo "1. Новий код збережено у вашій домівці."
echo "2. Зміни вже застосовані до поточної версії Vivaldi."
echo "3. Після оновлення Vivaldi запустіть: sudo $INSTALL_DIR/patch.sh"
