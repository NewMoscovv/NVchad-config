# 🚀 Руководство по установке и настройке

Пошаговое руководство по развёртыванию конфигурации Neovim для **Go-разработки**.

---

## 📋 Оглавление

1. [Требования](#требования)
2. [Установка Neovim](#установка-neovim)
3. [Установка конфигурации](#установка-конфигурации)
4. [Установка Go инструментов](#установка-go-инструментов)
5. [Установка форматеров](#установка-форматеров)
6. [Проверка установки](#проверка-установки)
7. [Устранение проблем](#устранение-проблем)

---

## 🎯 Требования

### Обязательные

| Компонент | Версия | Зачем |
|-----------|--------|-------|
| **Neovim** | ≥ 0.11.0 | Основная платформа |
| **git** | любая | Установка плагинов |
| **Go** | ≥ 1.21 | Для Go-разработки |

### Для Go-разработки

| Инструмент | Зачем |
|------------|-------|
| **gopls** | Языковой сервер (LSP) — автодополнение, диагностика |
| **gofumpt** | Строгий форматер Go |
| **goimports** | Управление импортами |
| **delve (dlv)** | Отладчик (DAP) |

### Опционально (для других языков)

| Инструмент | Зачем |
|------------|-------|
| **cargo/rustup** | Для установки stylua (Lua форматер) |
| **npm/node** | Для prettier (CSS/HTML форматер) |

---

## 💻 Установка Neovim

### macOS (Homebrew)
```bash
brew install neovim
nvim --version  # Проверка
```

### macOS (MacPorts)
```bash
sudo port install neovim
```

### Ubuntu/Debian
```bash
# Для свежей версии (≥ 0.11.0)
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt update
sudo apt install neovim
nvim --version
```

### Arch Linux
```bash
sudo pacman -S neovim
```

### Windows (Chocolatey)
```powershell
choco install neovim
```

### Windows (Scoop)
```powershell
scoop install neovim
```

### Из исходников (любая ОС)
```bash
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=Release
sudo make install
```

---

## 📦 Установка конфигурации

### Шаг 1: Резервное копирование (если есть старая конфигурация)

```bash
# Проверка
ls -la ~/.config/nvim

# Бэкап
mv ~/.config/nvim ~/.config/nvim.backup
```

### Шаг 2: Клонирование репозитория

```bash
# Клонирование в директорию конфигурации Neovim
git clone <URL_РЕПОЗИТОРИЯ> ~/.config/nvim

# Или копирование локальной версии
cp -r /path/to/nvim_backup ~/.config/nvim
```

### Шаг 3: Первый запуск

```bash
nvim
```

**Что происходит:**
1. Автоматически устанавливается `lazy.nvim` (менеджер плагинов)
2. Загружаются все плагины из `plugins/init.lua`
3. Применяется тема `ayu_dark`
4. Открывается Dashboard с ASCII-артом

**Время первой установки:** ~30-60 секунд (зависит от интернета)

### Шаг 4: Проверка установки плагинов

```vim
:Lazy
```

**Ожидаемый результат:** Все плагины отмечены зелёной галочкой ✓

**Установленные плагины:**
- `NvChad/NvChad` — основной фреймворк
- `neovim/nvim-lspconfig` — LSP конфигурация
- `stevearc/conform.nvim` — форматирование
- `mfussenegger/nvim-dap` — отладка
- `leoluz/nvim-dap-go` — Go отладка
- `rcarriga/nvim-dap-ui` — UI отладки
- `theHamsta/nvim-dap-virtual-text` — виртуальный текст
- `stevearc/dressing.nvim` — улучшенный UI

---

## 🔧 Установка Go инструментов

### 1. Gopls (языковой сервер)

```bash
go install golang.org/x/tools/gopls@latest
```

**Проверка:**
```bash
gopls version
```

**Ожидаемый вывод:**
```
gopls version: v0.x.x
```

**В Neovim:**
```vim
:LspInfo
```
Должно показать: `gopls: attached`

### 2. Gofumpt (строгий форматер)

```bash
go install mvdan.cc/gofumpt@latest
```

**Проверка:**
```bash
gofumpt --version
```

### 3. Goimports (управление импортами)

```bash
go install golang.org/x/tools/cmd/goimports@latest
```

**Проверка:**
```bash
goimports --version
```

### 4. Delve (отладчик)

```bash
go install github.com/go-delve/delve/cmd/dlv@latest
```

**Проверка:**
```bash
dlv version
```

**Важно для macOS:**
После установки может потребоваться подпись для отладки:
```bash
# См. https://github.com/go-delve/delve/blob/master/Documentation/macOS/install.md
```

### 5. Gotests (генерация тестов, опционально)

```bash
go install github.com/cweill/gotests/gotests@latest
```

---

## 🎨 Установка форматеров

### Для Lua (StyLua)

**Вариант 1: Через cargo (Rust)**
```bash
cargo install stylua
```

**Вариант 2: Через Homebrew (macOS)**
```bash
brew install stylua
```

**Вариант 3: Скачать бинарник**
```bash
# https://github.com/JohnnyMorganz/StyLua/releases
```

**Проверка:**
```bash
stylua --version
```

### Для CSS/HTML (Prettier)

**Через npm:**
```bash
npm install -g prettier
```

**Через yarn:**
```bash
yarn global add prettier
```

**Проверка:**
```bash
prettier --version
```

---

## ✅ Проверка установки

### 1. Проверка Neovim

```bash
nvim --version
```

**Ожидаемый результат:**
```
NVIM v0.11.x или выше
Features: +acl +iconv +tui
```

### 2. Проверка плагинов

```vim
:Lazy
```

**Ожидаемый результат:** Все плагины с галочкой ✓

### 3. Проверка LSP для Go

```vim
:LspInfo
```

**Ожидаемый результат:**
```
gopls: attached
root_dir: /path/to/your/project
```

### 4. Тестовый файл Go

Создайте файл `test.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
```

**Проверка:**
1. Откройте файл: `nvim test.go`
2. Должна работать автодополнение (начните вводить `fmt.`)
3. Должна работать навигация: `gd` (перейти к определению)
4. При сохранении (`:w`) файл должен форматироваться

### 5. Проверка форматирования

```vim
:edit test.go
:write
```

**Ожидаемый результат:** Файл отформатирован (gofumpt + goimports)

### 6. Проверка Git команд

Находясь в Git-репозитории:

```vim
:edit main.go
<leader>gt  # Git status
<leader>cm  # Git commits
```

**Ожидаемый результат:** Открывается Telescope со списком изменений/коммитов

### 7. Проверка отладки

Создайте тестовый файл `main_test.go`:

```go
package main

import "testing"

func TestExample(t *testing.T) {
    result := 2 + 2
    if result != 4 {
        t.Errorf("expected 4, got %d", result)
    }
}
```

**Проверка:**
```vim
:edit main_test.go
<leader>dt  # Debug test
```

**Ожидаемый результат:** Запускается отладчик, открывается UI с переменными

---

## 🐛 Устранение проблем

### Проблема: Neovim не запускается

**Решение:**
```bash
# Проверка версии
nvim --version

# Если версия < 0.11.0 — обновите
brew upgrade neovim  # macOS
sudo apt update && sudo apt upgrade neovim  # Ubuntu
```

### Проблема: Плагины не загружаются

**Решение 1: Очистить кэш**
```bash
rm -rf ~/.local/share/nvim/lazy
rm -rf ~/.local/share/nvim/base46
nvim
```

**Решение 2: Принудительная установка**
```vim
:Lazy sync
```

**Решение 3: Проверить интернет-соединение**
```bash
ping github.com
```

### Проблема: Gopls не работает

**Решение 1: Проверить установку**
```bash
which gopls
gopls version
```

**Решение 2: Переустановить**
```bash
go install golang.org/x/tools/gopls@latest
```

**Решение 3: Проверить PATH**

Добавить в `~/.bashrc` или `~/.zshrc`:
```bash
export PATH=$PATH:$(go env GOPATH)/bin
```

Применить:
```bash
source ~/.bashrc  # или source ~/.zshrc
```

**Решение 4: Проверить в Neovim**
```vim
:LspInfo
:LspRestart
```

**Решение 5: Проверить логи**
```vim
:messages
```

### Проблема: Форматирование не работает

**Решение 1: Проверить форматер**
```bash
which stylua    # для Lua
which prettier  # для CSS/HTML
which gofumpt   # для Go
```

**Решение 2: Проверить conform.nvim**
```vim
:ConformInfo
```

**Решение 3: Форматировать вручную**
```vim
:Format
```

### Проблема: Отладка не работает

**Решение 1: Проверить Delve**
```bash
which dlv
dlv version
```

**Решение 2: Проверить dap-go**
```vim
:Lazy
```
Убедитесь что `nvim-dap-go` установлен.

**Решение 3: Проверить конфигурацию**

В `configs/dap.lua` должны быть маппинги `<leader>db`, `<leader>dc`, и т.д.

### Проблема: Тема не применяется

**Решение:**
```vim
:lua vim.g.base46_cache = vim.fn.stdpath("data") .. "/base46/"
:source $MYVIMRC
```

Или удалить кэш:
```bash
rm -rf ~/.local/share/nvim/base46
nvim
```

### Проблема: Медленная загрузка

**Решение 1: Проверить время загрузки плагинов**
```vim
:Lazy profile
```

**Решение 2: Отключить неиспользуемые плагины**

В `plugins/init.lua` закомментировать ненужные:
```lua
-- { "автор/плагин" },
```

### Проблема: Ошибки при запуске

**Решение 1: Посмотреть лог**
```vim
:messages
```

**Решение 2: Проверить файл лога**
```bash
cat ~/.local/state/nvim/nvim.log
```

**Решение 3: Запустить в безопасном режиме**
```bash
nvim --clean
```

---

## 🔧 Дополнительная настройка

### Настройка Go окружения

Добавить в `~/.bashrc` или `~/.zshrc`:

```bash
# Go пути
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Go переменные
export GO111MODULE=on
```

Применить:
```bash
source ~/.bashrc  # или source ~/.zshrc
```

### Настройка Node.js для плагинов

```bash
# Установить LTS версию
nvm install --lts
nvm use --lts
```

### Настройка Python для плагинов

```bash
pip install pynvim
```

---

## 📊 Чек-лист установки

- [ ] Neovim ≥ 0.11.0 установлен
- [ ] git установлен
- [ ] Конфигурация скопирована в `~/.config/nvim`
- [ ] Первый запуск прошёл успешно (открылся Dashboard)
- [ ] Все плагины загружены (`:Lazy` показывает галочки)
- [ ] Gopls установлен и работает (`:LspInfo` показывает "attached")
- [ ] Gofumpt установлен
- [ ] Delve установлен (для отладки)
- [ ] StyLua установлен (для Lua)
- [ ] Prettier установлен (для CSS/HTML)
- [ ] Форматирование при сохранении работает
- [ ] Git команды работают (внутри репозитория)
- [ ] Отладка работает (`<leader>dt` запускает тест)

---

## 🎯 Быстрый старт (TL;DR)

```bash
# 1. Установить Neovim
brew install neovim

# 2. Склонировать конфигурацию
git clone <URL> ~/.config/nvim

# 3. Установить Go инструменты
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest

# 4. Установить форматеры
cargo install stylua
npm install -g prettier

# 5. Запустить Neovim
nvim

# 6. Проверить установку
:Lazy
:LspInfo
```

---

## 📚 Полезные команды

### Управление плагинами
```vim
:Lazy           # Открыть менеджер плагинов
:Lazy sync      # Обновить все плагины
:Lazy clean     # Удалить неиспользуемые
:Lazy check     # Проверить обновления
:Lazy profile   # Показать время загрузки
```

### LSP команды
```vim
:LspInfo        # Информация о LSP
:LspRestart     # Перезапустить LSP
:LspStart       # Запустить LSP
:LspStop        # Остановить LSP
```

### Отладка
```vim
:DapContinue    # Продолжить отладку
:DapTerminate   # Завершить отладку
```

### Форматирование
```vim
:Format         # Форматировать файл вручную
:ConformInfo    # Информация о форматере
```

---

## 🔗 Полезные ссылки

- [Официальная документация Neovim](https://neovim.io/doc/)
- [NvChad документация](https://nvchad.com/docs/quickstart/install)
- [Gopls документация](https://github.com/golang/tools/blob/master/gopls/README.md)
- [Lazy.nvim документация](https://github.com/folke/lazy.nvim)
- [Conform.nvim документация](https://github.com/stevearc/conform.nvim)
- [nvim-dap документация](https://github.com/mfussenegger/nvim-dap)
- [Delve отладчик](https://github.com/go-delve/delve)

---

*Руководство актуально для NvChad v2.5 и Neovim ≥ 0.11.0*

**Последнее обновление:** Апрель 2026
