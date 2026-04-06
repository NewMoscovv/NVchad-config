# 📚 Документация конфигурации Neovim (NvChad)

Добро пожаловать в документацию конфигурации **Neovim** на основе фреймворка **NvChad v2.5**.

---

## 🎯 О этой документации

Эта документация описывает **конкретную конфигурацию** для **Go-разработки** с поддержкой:

- ✅ **LSP** (gopls) — автодополнение, диагностика, навигация
- ✅ **DAP** (delve) — отладка Go-кода
- ✅ **Форматирование** — gofumpt + goimports для Go, stylua для Lua, prettier для CSS/HTML
- ✅ **Git интеграция** — работа с Git через Telescope
- ✅ **Markdown просмотр** — красивый рендер `.md` файлов прямо в Neovim
- ✅ **Темы оформления** — ayu_dark (настраивается)

---

## 📖 Содержание

### 📘 [Полное руководство по конфигурации](./CONFIGURATION_GUIDE.md)

**Детальное описание всех файлов конфигурации с разбором кода:**

| Файл | Описание |
|------|----------|
| `init.lua` | Точка входа, bootstrap lazy.nvim, загрузка плагинов |
| `options.lua` | Настройки редактора (номера строк, цвета) |
| `chadrc.lua` | Конфигурация UI и темы (ayu_dark, Dashboard) |
| `mappings.lua` | Пользовательские клавиатурные сокращения |
| `autocmds.lua` | Автокоманды NvChad |
| `configs/lsp.lua` | LSP настройка (gopls для Go, автоимпорты) |
| `configs/dap.lua` | DAP настройка (отладка Go через delve) |
| `configs/conform.lua` | Форматирование кода (gofumpt, goimports, stylua, prettier) |
| `configs/lazy.lua` | Менеджер плагинов, оптимизация производительности |
| `plugins/init.lua` | Список дополнительных плагинов |

**Объём:** 400+ строк подробных объяснений с комментариями

---

### ⌨️ [Справочник горячих клавиш](./KEYBINDINGS_REFERENCE.md)

**Полный список всех клавишных комбинаций с разделением:**

1. **Реальные хоткеи этой конфигурации** — проверены в коде
   - `;` — командная строка
   - `fd` — выход из insert mode
   - `<leader>h` — Dashboard
   - `<leader>gt` — Git status
   - `<leader>cm` — Git commits
   - `<leader>gi` — организовать Go импорты
   - `<leader>db/dc/dr/du/dt/dl` — отладка (DAP)

2. **Стандартные хоткеи NvChad** — с пометкой что могут измениться
   - Навигация по окнам
   - Telescope поиск
   - LSP функции
   - Базовые команды Vim

**Важно:** Справочник явно разделяет что есть в конфигурации, а что предоставляется NvChad по умолчанию.

---

### 🚀 [Руководство по установке](./INSTALLATION_GUIDE.md)

**Пошаговая инструкция:**

- Установка Neovim (macOS, Linux, Windows)
- Установка конфигурации
- Установка Go инструментов (gopls, gofumpt, delve, goimports)
- Установка форматеров (stylua, prettier)
- Проверка установки
- Устранение проблем

---

## 🎯 Быстрый старт

### 1. Установка (5 минут)

```bash
# Установить Neovim
brew install neovim

# Склонировать конфигурацию
git clone <repository> ~/.config/nvim

# Установить Go инструменты
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install golang.org/x/tools/cmd/goimports@latest

# Запустить
nvim
```

### 2. Проверка (1 минута)

```vim
:Lazy      # Проверить плагины (все должны быть с галочкой ✓)
:LspInfo   # Проверить LSP (gopls должен быть "attached")
```

### 3. Начало работы

| Клавиша | Действие |
|---------|----------|
| `<leader>h` | Открыть Dashboard |
| `<leader>ff` | Найти файл (Telescope) |
| `<leader>fw` | Найти текст (live grep) |
| `<leader>e` | Открыть дерево файлов (NvimTree) |
| `;` | Командная строка |
| `fd` (в insert mode) | Выход из режима вставки |

---

## 📊 Структура конфигурации

```
nvim_backup/
├── init.lua                 # Точка входа
├── lua/
│   ├── options.lua          # Настройки редактора
│   ├── mappings.lua         # Горячие клавиши (пользовательские)
│   ├── autocmds.lua         # Автокоманды
│   ├── chadrc.lua           # UI настройки (тема, Dashboard)
│   ├── configs/
│   │   ├── lazy.lua         # Менеджер плагинов
│   │   ├── lsp.lua          # LSP (gopls для Go, автоимпорты)
│   │   ├── dap.lua          # Отладка (DAP для Go)
│   │   └── conform.lua      # Форматирование (gofumpt, goimports, stylua, prettier)
│   └── plugins/
│       └── init.lua         # Список плагинов (lspconfig, dap, conform, dap-ui, ...)
└── docs/
    ├── README.md            # Этот файл
    ├── CONFIGURATION_GUIDE.md
    ├── KEYBINDINGS_REFERENCE.md
    └── INSTALLATION_GUIDE.md
```

---

## 🔧 Основные возможности

### Language Server Protocol (LSP)

**Настроено для Go (gopls):**

| Возможность | Описание |
|------------|----------|
| Автодополнение | Через nvim-cmp с LSP |
| Переход к определению | `gd` |
| Поиск всех ссылок | `gr` |
| Документация | `K` (hover) |
| Диагностика | Ошибки/предупреждения в реальном времени |
| Автоимпорты | При сохранении (`BufWritePre`) + вручную `<leader>gi` |
| Форматирование | gofumpt + goimports при сохранении |

**Настройки gopls:**
```lua
settings = {
  gopls = {
    completeUnimported = true,    -- Автодополнение неимпортированных пакетов
    usePlaceholders = true,       -- Плейсхолдеры для параметров
    staticcheck = true,           -- Статический анализ
    gofumpt = true,               -- Строгий форматер
    analyses = { unusedparams = true },
  },
}
```

### Debug Adapter Protocol (DAP)

**Настроено для Go (delve):**

| Клавиши | Действие |
|---------|----------|
| `<leader>db` | Поставить/снять breakpoint 🔴 |
| `<leader>dc` | Запустить/продолжить отладку ▶️ |
| `<leader>dr` | Открыть Debug REPL |
| `<leader>du` | Показать/скрыть UI отладки |
| `<leader>dt` | Отладить ближайший тест |
| `<leader>dl` | Повторить последнюю отладку |

**UI отладки (dapui) показывает:**
- Переменные (локальные, глобальные)
- Стек вызовов
- Список breakpoints
- Консоль output

### Форматирование

**Автоматическое при сохранении:**

| Язык | Форматеры |
|------|-----------|
| Go | gofumpt → goimports |
| Lua | stylua |
| CSS | prettier |
| HTML | prettier |

**Настройки:**
```lua
format_on_save = {
  timeout_ms = 500,      -- Таймаут форматирования
  lsp_fallback = true,   -- Если нет форматера — использовать LSP
}
```

### Markdown просмотр

**Настроено через `render-markdown.nvim`:**

| Возможность | Описание |
|------------|----------|
| Встроенный рендер | Markdown отображается прямо в буфере, без браузера |
| Заголовки и списки | Красивое оформление заголовков, bullets и таблиц |
| Комфортное редактирование | В режиме редактирования показывается сырой Markdown |
| Управление командами | `:RenderMarkdown toggle`, `:RenderMarkdown enable`, `:RenderMarkdown disable` |

**Как пользоваться:**
```vim
:edit README.md
:RenderMarkdown toggle
```

**Важно:** Для работы рендера используются Treesitter-парсеры `markdown`, `markdown_inline`, `html`, `yaml`.

### Git интеграция

**Команды через Telescope:**

| Клавиши | Команда | Описание |
|---------|---------|----------|
| `<leader>gt` | `git_status` | Показать изменения в репозитории |
| `<leader>cm` | `git_commits` | История коммитов |

**Важно:** Команды работают только внутри Git-репозитория. Если файл не в репозитории, покажется предупреждение.

---

## 🎨 Темы оформления

**Текущая тема:** `ayu_dark`

**Как изменить:** В `chadrc.lua`:
```lua
M.base46 = {
  theme = "catppuccin",  -- или любая другая тема
}
```

**Доступные темы:** ayu_dark/light, catppuccin, dracula, onedark, gruvbox, nord, tokyonight, everforest, kanagawa и 20+ других.

**Кастомизация:**
```lua
vim.api.nvim_set_hl(0, "NvDashAscii", { fg = "#00ff00" })  -- Зелёный ASCII-арт
```

---

## 📦 Плагины

### Основные плагины (из `plugins/init.lua`)

| Плагин | Назначение |
|--------|------------|
| `neovim/nvim-lspconfig` | Конфигурация LSP серверов |
| `stevearc/conform.nvim` | Форматирование кода |
| `mfussenegger/nvim-dap` | Debug Adapter Protocol |
| `leoluz/nvim-dap-go` | Go интеграция для DAP |
| `rcarriga/nvim-dap-ui` | UI для отладки |
| `theHamsta/nvim-dap-virtual-text` | Виртуальный текст значений переменных |
| `stevearc/dressing.nvim` | Улучшенный UI для select/input |
| `MeanderingProgrammer/render-markdown.nvim` | Рендер Markdown прямо в буфере Neovim |

### Встроенные в NvChad (из `NvChad/NvChad`)

- **Telescope** — fuzzy поиск файлов и текста
- **Treesitter** — подсветка синтаксиса
- **nvim-cmp** — движок автодополнения
- **nvim-tree** — дерево файлов
- **NvDash** — главный экран (Dashboard)
- **Base46** — движок тем оформления

---

## 💡 Советы для начинающих

### 1. Начните с Dashboard
```vim
<leader>h  # Открыть главный экран с горячими клавишами
```

### 2. Используйте поиск файлов
```vim
<leader>ff  # Найти файл по имени (Telescope)
```

### 3. Быстрая навигация по коду
```vim
gd  # Перейти к определению функции
gr  # Найти все ссылки на символ
K   # Показать документацию (hover)
```

### 4. Go разработка
```vim
<leader>gi  # Организовать импорты (автоматически при сохранении)
<leader>db  # Поставить breakpoint
<leader>dc  # Запустить отладку
<leader>dt  # Отладить тест
```

### 5. Git workflow
```vim
<leader>gt  # Показать изменения
<leader>cm  # История коммитов
:RenderMarkdown toggle  # Включить/выключить рендер Markdown
```

---

## 🐛 Решение проблем

### Частые проблемы

| Проблема | Решение |
|----------|---------|
| Плагины не грузятся | `:Lazy sync` |
| Gopls не работает | `go install golang.org/x/tools/gopls@latest` затем `:LspRestart` |
| Тема не применяется | `rm -rf ~/.local/share/nvim/base46` и перезапустить Neovim |
| Форматирование не работает | `:ConformInfo` для диагностики |
| Отладка не работает | Проверить `dlv version`, установить: `go install github.com/go-delve/delve/cmd/dlv@latest` |
| Markdown рендер не работает | `:TSInstall markdown markdown_inline html yaml` и затем `:RenderMarkdown enable` |

### Логи и диагностика

```vim
:messages          # Показать сообщения об ошибках
:LspInfo           # Информация о подключенных LSP
:LspRestart        # Перезапустить LSP
:ConformInfo       # Информация о форматерах
:DapInfo           # Информация об отладке (если доступно)
:Lazy              # Менеджер плагинов
:Lazy profile      # Время загрузки каждого плагина
:RenderMarkdown toggle  # Переключить рендер Markdown
```

### Файлы логов

```bash
~/.local/state/nvim/nvim.log
```

---

## 📚 Дополнительные ресурсы

### Официальная документация

- [Neovim](https://neovim.io/doc/)
- [NvChad](https://nvchad.com/docs/)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [conform.nvim](https://github.com/stevearc/conform.nvim)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)

### Go инструменты

- [gopls документация](https://github.com/golang/tools/blob/master/gopls/README.md)
- [delve отладчик](https://github.com/go-delve/delve)
- [gofumpt](https://github.com/mvdan/gofumpt)

### Сообщество

- [NvChad Discord](https://discord.gg/nvchad)
- [Neovim Reddit](https://reddit.com/r/neovim)
- [NvChad GitHub Discussions](https://github.com/NvChad/NvChad/discussions)

---

## 📝 Лицензия

Документация распространяется под той же лицензией, что и основной проект.

---

*Документация актуальна для NvChad v2.5 и Neovim ≥ 0.11.0*

**Последнее обновление:** Апрель 2026
