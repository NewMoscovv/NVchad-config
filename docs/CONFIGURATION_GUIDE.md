# Полная документация конфигурации Neovim (NvChad)

Эта документация описывает **все аспекты** конфигурации Neovim на основе фреймворка **NvChad v2.5**.

---

## 📋 Оглавление

1. [Общая архитектура](#общая-архитектура)
2. [Точка входа (init.lua)](#точка-входа-initlua)
3. [Системные настройки (options.lua)](#системные-настройки-optionslua)
4. [Конфигурация UI (chadrc.lua)](#конфигурация-ui-chadrc.lua)
5. [Клавиатурные маппинги (mappings.lua)](#клавиатурные-маппинги-mappingslua)
6. [Автокоманды (autocmds.lua)](#автокоманды-autocmdslua)
7. [Менеджер плагинов (configs/lazy.lua)](#менеджер-плагинов-configslazylua)
8. [Language Server Protocol (configs/lsp.lua)](#language-server-protocol-configslsplua)
9. [Отладчик (configs/dap.lua)](#отладчик-configsdaplua)
10. [Форматирование кода (configs/conform.lua)](#форматирование-кода-configsconformlua)
11. [Плагины (plugins/init.lua)](#плагины-pluginsinitlua)
12. [Справочник клавишных комбинаций](#справочник-клавишных-комбинаций)

---

## 🏗 Общая архитектура

Конфигурация построена по модульному принципу:

```
nvim_backup/
├── init.lua              # Точка входа, инициализация lazy.nvim
├── lua/
│   ├── options.lua       # Настройки редактора (номера строк, отступы и т.д.)
│   ├── mappings.lua      # Клавиатурные сокращения
│   ├── autocmds.lua      # Автокоманды (события)
│   ├── chadrc.lua        # Настройки UI NvChad (тема, dashboard)
│   ├── configs/
│   │   ├── lazy.lua      # Конфигурация менеджера плагинов
│   │   ├── lsp.lua       # Настройки языкового сервера (gopls для Go)
│   │   ├── dap.lua       # Настройки отладчика (DAP)
│   │   └── conform.lua   # Настройки форматировщика кода
│   └── plugins/
│       └── init.lua      # Список дополнительных плагинов
```

### Принцип работы

1. **init.lua** загружается при старте Neovim
2. Bootstrap'ится **lazy.nvim** (менеджер плагинов)
3. Загружаются все плагины
4. Применяется тема оформления
5. Загружаются модули: `options` → `autocmds` → `mappings`

---

## 🚀 Точка входа (init.lua)

### Полный код
```lua
vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
```

### Подробное описание

#### 1. Переменные окружения

| Переменная | Значение | Описание |
|-----------|----------|----------|
| `vim.g.base46_cache` | `stdpath("data")/base46/` | Путь к кэшу тем оформления base46 |
| `vim.g.mapleader` | `" "` (пробел) | **Лидер-клавиша** для всех комбинаций с `<leader>` |

#### 2. Bootstrap lazy.nvim

**Что происходит:**
```lua
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end
```

- Проверяется наличие `lazy.nvim` в директории данных Neovim
- Если не найден — **автоматически клонируется** репозиторий с GitHub
- Используется стабильная ветка (`--branch=stable`)
- `--filter=blob:none` — экономия трафика (не загружаются файлы истории)

**Путь добавляется в runtimepath:**
```lua
vim.opt.rtp:prepend(lazypath)
```

#### 3. Настройка плагинов

```lua
require("lazy").setup({
  {
    "NvChad/NvChad",        -- Основной пакет NvChad
    lazy = false,           -- Загружать сразу (не откладывать)
    branch = "v2.5",        -- Конкретная версия
    import = "nvchad.plugins", -- Импортировать модули плагинов NvChad
  },
  { import = "plugins" },   -- Импортировать пользовательские плагины из lua/plugins/
}, lazy_config)
```

**Параметры:**
- `lazy = false` — NvChad загружается сразу, не лениво
- `branch = "v2.5"` — фиксирует версию NvChad
- `import = "nvchad.plugins"` — подключает стандартные плагины NvChad
- `import = "plugins"` — подключает ваши плагины из `lua/plugins/init.lua`

#### 4. Загрузка темы

```lua
dofile(vim.g.base46_cache .. "defaults")    -- Базовые цвета
dofile(vim.g.base46_cache .. "statusline")  -- Цвета статусной строки
```

Тема определяется в `chadrc.lua` (текущая: `ayu_dark`)

#### 5. Порядок загрузки модулей

```lua
require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
```

**Почему mappings загружаются через vim.schedule?**
Чтобы все плагины успели инициализироваться и их команды были доступны для маппинга.

---

## ⚙️ Системные настройки (options.lua)

### Полный код
```lua
require "nvchad.options"

vim.opt.number = true
vim.opt.relativenumber = true

vim.api.nvim_set_hl(0, "NvDashAscii", { fg = "#00ff00" })
```

### Подробное описание

#### 1. Базовые настройки NvChad

```lua
require "nvchad.options"
```

Загружает стандартные настройки NvChad:
- `expandtab` — пробелы вместо табов
- `shiftwidth = 2` — отступ 2 пробела
- `tabstop = 2` — таб = 2 пробела
- `ignorecase` — игнорировать регистр при поиске
- `smartcase` — умный поиск (если есть заглавные — регистр важен)
- `cursorline` — подсветка текущей строки
- `signcolumn = yes` — всегда показывать колонку знаков
- `updatetime = 200` — быстрее обновлять буфер
- `timeoutlen = 300` — задержка лидер-клавиш

#### 2. Номера строк

```lua
vim.opt.number = true        -- Абсолютные номера строк
vim.opt.relativenumber = true -- Относительные номера (для навигации)
```

**Как это выглядит:**
```
  5 │ 2  ← текущая строка (абсолютный номер)
  6 │ 1
  7 │ 0  ← текущая строка (относительный: 0)
  8 │ 1
  9 │ 2
```

**Преимущества:**
- Быстрое перемещение: `5j` прыгнет на 5 строк вниз
- Видно расстояние до других строк

#### 3. Кастомизация Dashboard

```lua
vim.api.nvim_set_hl(0, "NvDashAscii", { fg = "#00ff00" })
```

Устанавливает **зелёный цвет** (`#00ff00`) для ASCII-арта на главном экране (NvDash).

---

## 🎨 Конфигурация UI (chadrc.lua)

### Полный код
```lua
---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "ayu_dark",

	hl_override = {
		Comment = { italic = true },
		["@comment"] = { italic = true },
	},
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣤⣀...",
    -- ... ASCII арт (кастомный + NvChad логотип)
  },
}

M.options = {
  number = true,
  relativenumber = true,
}

return M
```

### Подробное описание

#### 1. Тема оформления

```lua
M.base46 = {
  theme = "ayu_dark",
```

**Текущая тема:** `ayu_dark` — тёмная тема с синими/оранжевыми акцентами

**Доступные темы NvChad:**
- `ayu_dark`, `ayu_light`
- `catppuccin`, `catppuccin_latte`, `catppuccin_frappe`, `catppuccin_macchiato`, `catppuccin_mocha`
- `dracula`
- `onedark`, `onedark_vivid`
- `gruvbox`, `gruvbox_light`
- `nord`
- `tokyonight`, `tokyonight_storm`, `tokyonight_day`
- `everforest`, `everforest_light`
- `kanagawa`, `kanagawa_dragon`
- И ещё 20+ тем

**Как изменить:**
```lua
M.base46 = {
  theme = "catppuccin",  -- Новая тема
}
```

#### 2. Переопределение подсветки

```lua
hl_override = {
  Comment = { italic = true },
  ["@comment"] = { italic = true },
}
```

**Что делает:**
- `Comment` — делает комментарии *курсивными*
- `["@comment"]` — то же для Treesitter (парсер синтаксиса)

**Доступные параметры:**
- `fg` — цвет текста (hex: `"#ff0000"` или название: `"red"`)
- `bg` — цвет фона
- `bold` — жирный (`true`/`false`)
- `italic` — курсив (`true`/`false`)
- `underline` — подчёркивание (`true`/`false`)
- `undercurl` — волнистая линия (`true`/`false`)
- `strikethrough` — зачёркивание (`true`/`false`)

#### 3. Dashboard (NvDash)

```lua
M.nvdash = {
  load_on_startup = true,
  header = { ... }
}
```

**Параметры:**

| Параметр | Значение | Описание |
|---------|----------|----------|
| `load_on_startup` | `true` | Показывать при запуске Neovim |
| `header` | таблица строк | ASCII-арт для отображения |

**Текущий header:**
- Верхняя часть — кастомный ASCII-арт (украшение)
- Нижняя часть — логотип **NvChad**

**Как отключить:**
```lua
M.nvdash = {
  load_on_startup = false,
}
```

#### 4. Опции редактора

```lua
M.options = {
  number = true,
  relativenumber = true,
}
```

Дублирует настройки из `options.lua` для согласованности с UI.

---

## ⌨️ Клавиатурные маппинги (mappings.lua)

### Полный код
```lua
require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "fd", "<ESC>", { desc = "Exit insert mode" })

local function git_root()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local start_dir = buf_path ~= "" and vim.fs.dirname(buf_path) or vim.uv.cwd()
  local git_dir = vim.fs.find(".git", { path = start_dir, upward = true })[1]

  if git_dir then
    return vim.fs.dirname(git_dir)
  end
end

local function telescope_git_builtin(picker, missing_msg)
  return function()
    local root = git_root()
    if not root then
      vim.notify(missing_msg, vim.log.levels.WARN)
      return
    end

    require("telescope.builtin")[picker] { cwd = root }
  end
end

map("n", "<leader>gt", telescope_git_builtin("git_status", "Git repo not found for current file"), {
  desc = "telescope git status",
})
map("n", "<leader>cm", telescope_git_builtin("git_commits", "Git repo not found for current file"), {
  desc = "telescope git commits",
})


vim.keymap.set("n", "<leader>h", function()
  vim.cmd("Nvdash")
end, { desc = "Open Dashboard" })



-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
```

### Подробное описание

#### 1. Базовые маппинги NvChad

```lua
require "nvchad.mappings"
```

Загружает стандартные маппинги NvChad (см. [Справочник](#справочник-клавишных-комбинаций)).

#### 2. Пользовательские маппинги

##### Быстрый доступ к командной строке

```lua
map("n", ";", ":", { desc = "CMD enter command mode" })
```

| Параметр | Значение |
|---------|----------|
| Режим | `n` (normal) |
| Клавиша | `;` |
| Действие | `:` (командная строка) |

**Зачем:** Быстрый ввод команд без Shift+;

##### Выход из режима вставки

```lua
map("i", "fd", "<ESC>", { desc = "Exit insert mode" })
```

| Параметр | Значение |
|---------|----------|
| Режим | `i` (insert) |
| Клавиши | `fd` (быстрое нажатие f, затем d) |
| Действие | `<ESC>` (выход) |

**Зачем:** Альтернатива Escape для тех, кто использует Vim-style (home row)

#### 3. Git-функции через Telescope

##### Функция определения корня Git-репозитория

```lua
local function git_root()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local start_dir = buf_path ~= "" and vim.fs.dirname(buf_path) or vim.uv.cwd()
  local git_dir = vim.fs.find(".git", { path = start_dir, upward = true })[1]

  if git_dir then
    return vim.fs.dirname(git_dir)
  end
end
```

**Алгоритм работы:**
1. Получает путь текущего буфера
2. Если буфер пустой — использует текущую директорию
3. Ищет папку `.git` вверх по дереву директорий (`upward = true`)
4. Возвращает корень репозитория (родительскую директорию `.git`)

**Пример:**
```
/home/user/project/
├── .git/
├── src/
│   └── main.go  ← если открыт этот файл
```
Функция вернёт `/home/user/project/`

**Если Git не найден:** Возвращает `nil`

##### Функция для Git-команд Telescope

```lua
local function telescope_git_builtin(picker, missing_msg)
  return function()
    local root = git_root()
    if not root then
      vim.notify(missing_msg, vim.log.levels.WARN)
      return
    end

    require("telescope.builtin")[picker] { cwd = root }
  end
end
```

**Параметры:**
- `picker` — имя команды Telescope (`git_status`, `git_commits`)
- `missing_msg` — сообщение если Git не найден

**Логика:**
1. Находит корень Git
2. Если не найден — показывает предупреждение через `vim.notify`
3. Запускает Telescope с `cwd` (рабочей директорией) = корень репозитория

##### Маппинг: Git Status

```lua
map("n", "<leader>gt", telescope_git_builtin("git_status", "Git repo not found for current file"), {
  desc = "telescope git status",
})
```

**Что показывает:**
- Изменённые файлы (modified)
- Новые файлы (untracked)
- Удалённые файлы (deleted)
- Staged изменения (подготовленные к коммиту)

**Действия в Telescope:**
- Выбрать файл — открыть
- `Ctrl+s` — staged/unstaged
- `Ctrl+r` — revert changes
- `Ctrl+d` — discard changes

##### Маппинг: Git Commits

```lua
map("n", "<leader>cm", telescope_git_builtin("git_commits", "Git repo not found for current file"), {
  desc = "telescope git commits",
})
```

**Что показывает:**
- История коммитов с сообщениями
- Автор и дата коммита
- Изменённые файлы в коммите

**Действия в Telescope:**
- Выбрать коммит — показать diff
- `Ctrl+y` — copy commit hash
- `Ctrl+o` — checkout commit

#### 4. Открытие Dashboard

```lua
vim.keymap.set("n", "<leader>h", function()
  vim.cmd("Nvdash")
end, { desc = "Open Dashboard" })
```

**Что делает:**
- Открывает главный экран NvChad
- Показывает ASCII-арт (из `chadrc.lua`)
- Отображает горячие клавиши

**Зачем:** Быстрый доступ к dashboard после его закрытия

#### 5. Закомментированный маппинг

```lua
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
```

**Что должно было делать:** Сохранение файла по `Ctrl+s` во всех режимах

**Почему закомментировано:** Возможно, конфликт с терминалом или не нужно

---

## 🔔 Автокоманды (autocmds.lua)

### Полный код
```lua
require "nvchad.autocmds"
```

### Подробное описание

#### Базовые автокоманды NvChad

Загружает стандартные автокоманды NvChad:

**1. Highlight on Yank** — подсветка при копировании
```lua
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})
```
Подсвечивает скопированный текст на 200мс

**2. Resize splits** — авторесайз при изменении размера окна
```lua
vim.api.nvim_create_autocmd("VimResized", {
  command = "tabdo wincmd ="
})
```
Выравнивает все окна при ресайзе терминала

**3. Auto close terminal** — закрывать терминал при успешном выполнении
```lua
vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*:q*",
  command = "if expand('%') ==# '' | bdelete | endif"
})
```

**4. Check time** — проверка изменений файлов на диске
```lua
vim.api.nvim_create_autocmd("FocusGained", {
  command = "checktime"
})
```
Проверяет не изменились ли файлы на диске при фокусе окна

---

## 📦 Менеджер плагинов (configs/lazy.lua)

### Полный код
```lua
return {
  defaults = { lazy = true },
  install = { colorscheme = { "nvchad" } },

  ui = {
    icons = {
      ft = "",
      lazy = "󰂠 ",
      loaded = "",
      not_loaded = "",
    },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
      },
    },
  },
}
```

### Подробное описание

#### 1. Настройки по умолчанию

```lua
defaults = { lazy = true }
```

**Что делает:** Все плагины загружаются **лениво** (только когда нужны)

**Преимущества:**
- Быстрее запуск Neovim
- Меньше потребление памяти
- Плагины загружаются только при открытии соответствующих файлов

#### 2. Настройки установки

```lua
install = { colorscheme = { "nvchad" } }
```

**Что делает:** При первой установке использует тему `nvchad` для UI менеджера плагинов

#### 3. Настройки UI

```lua
ui = {
  icons = {
    ft = "",           -- Иконка типа файла
    lazy = "󰂠 ",        -- Иконка lazy.nvim
    loaded = "",       -- Плагин загружен (галочка)
    not_loaded = "",   -- Плагин не загружен (круг)
  },
}
```

**Где отображается:**
- При запуске `:Lazy`
- В статусной строке загрузки

#### 4. Оптимизация производительности

```lua
performance = {
  rtp = {
    disabled_plugins = { ... }
  }
}
```

**Отключённые плагины (28 штук):**

| Плагин | Описание | Почему отключен |
|--------|----------|-----------------|
| `2html_plugin`, `tohtml` | Конвертация в HTML | Редко используется |
| `getscript`, `getscriptPlugin` | Загрузка скриптов из интернета | Небезопасно |
| `gzip` | Работа с gzip | Не нужно в редакторе |
| `logipat` | Логирование паттернов | Устарело |
| `netrw*` (5 плагинов) | Файловый менеджер | Отключён в пользу текущего набора плагинов и runtime-настроек |
| `matchit` | Парные теги | Есть лучшие альтернативы |
| `tar`, `tarPlugin` | TAR архивы | Редко нужно |
| `rrhelper` | Вспомогательный плагин | Не используется |
| `spellfile_plugin` | Проверка орфографии | Отключена |
| `vimball`, `vimballPlugin` | Формат vimball | Устарело |
| `zip`, `zipPlugin` | ZIP архивы | Редко нужно |
| `tutor` | Обучающий режим | Не нужен |
| `rplugin` | Remote plugins | Не используется |
| `syntax`, `synmenu` | Синтаксис Vim | Заменён на Treesitter |
| `optwin` | Окно опций | Не нужно |
| `compiler` | Компилятор | Не используется |
| `bugreport` | Отчёт об ошибках | Не нужно |
| `ftplugin` | Плагины по типам файлов | Отключён в этой конфигурации |

**Важно:** В файле указано только то, что эти runtime-плагины отключены. Точное влияние на скорость старта отдельно не измерялось в этой документации.

---

## 🔧 Language Server Protocol (configs/lsp.lua)

### Полный код
```lua
local nvchad_lsp = require "nvchad.configs.lspconfig"

nvchad_lsp.defaults()

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
  capabilities = nvchad_lsp.capabilities,
  on_init = nvchad_lsp.on_init,
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      staticcheck = true,
      gofumpt = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
})

local goimports_group = vim.api.nvim_create_augroup("go_auto_imports", { clear = true })

local function organize_go_imports(bufnr)
  local clients = vim.lsp.get_clients { bufnr = bufnr, name = "gopls" }
  if #clients == 0 then
    return
  end

  local client = clients[1]
  local last_line_nr = vim.api.nvim_buf_line_count(bufnr)
  local last_line = vim.api.nvim_buf_get_lines(bufnr, last_line_nr - 1, last_line_nr, false)[1] or ""
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ["end"] = {
        line = math.max(last_line_nr - 1, 0),
        character = #last_line,
      },
    },
  }

  params.context = {
    only = { "source.organizeImports" },
    diagnostics = vim.diagnostic.get(bufnr),
  }

  local result = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
  if not result or not result.result then
    return
  end

  for _, action in ipairs(result.result) do
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
    end

    if action.command then
      client:exec_cmd(action.command, { bufnr = bufnr })
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = goimports_group,
  pattern = "*.go",
  callback = function(args)
    organize_go_imports(args.buf)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = goimports_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "gopls" then
      return
    end

    vim.keymap.set("n", "<leader>gi", function()
      organize_go_imports(args.buf)
    end, {
      buffer = args.buf,
      desc = "Go organize imports",
    })
  end,
})

vim.lsp.enable "gopls"
```

### Подробное описание

#### 1. Инициализация LSP

```lua
local nvchad_lsp = require "nvchad.configs.lspconfig"
nvchad_lsp.defaults()
```

**Что делает:**
- Загружает стандартные настройки LSP от NvChad
- Настраивает `nvim-lspconfig`
- Устанавливает обработчики для:
  - Прогресс операций
  - Hover (документация по `K`)
  - Signature help (подпись функций)
  - Diagnostic (ошибки/предупреждения)

#### 2. Настройка gopls (Go Language Server)

##### Базовая конфигурация

```lua
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
```

**Параметры:**

| Параметр | Значение | Описание |
|---------|----------|----------|
| `cmd` | `["gopls"]` | Команда запуска сервера |
| `filetypes` | `go, gomod, gowork, gotmpl` | Типы файлов для активации LSP |
| `root_markers` | `go.work, go.mod, .git` | Маркеры корня проекта (ищутся вверх по дереву) |

**Как работает root_markers:**
LSP ищет вверх по дереву файлы в порядке приоритета:
1. `go.work` — workspace Go (приоритет 1)
2. `go.mod` — модуль Go (приоритет 2)
3. `.git` — корень Git (приоритет 3, fallback)

##### Capabilities

```lua
capabilities = nvchad_lsp.capabilities,
on_init = nvchad_lsp.on_init,
```

**capabilities** — возможности LSP клиента:
- Поддержка completion (автодополнение)
- Поддержка hover (документация)
- Поддержка diagnostics (ошибки)
- Интеграция с nvim-cmp (completion engine)

**on_init** — функция, вызываемая при инициализации сервера (настраивает дополнительные возможности)

##### Настройки gopls

```lua
settings = {
  gopls = {
    completeUnimported = true,    -- Автодополнение неимпортированных пакетов
    usePlaceholders = true,       -- Плейсхолдеры для параметров функции
    staticcheck = true,           -- Статический анализ кода
    gofumpt = true,               -- Строгий форматер
    analyses = {
      unusedparams = true,        -- Предупреждения о неиспользуемых параметрах
    },
  },
}
```

**Подробно о настройках:**

| Настройка | Значение | Эффект |
|----------|----------|--------|
| `completeUnimported` | `true` | Предлагает импорты при автодополнении (например, `fmt.Println` с автоимпортом `fmt`) |
| `usePlaceholders` | `true` | Вставляет `(param1, param2)` после названия функции при автодополнении |
| `staticcheck` | `true` | Включает строгий статический анализ (находит больше ошибок) |
| `gofumpt` | `true` | Использует gofumpt вместо gofmt (более строгий форматер) |
| `analyses.unusedparams` | `true` | Предупреждает о неиспользуемых параметрах функций |

#### 3. Автоимпорты для Go

##### Группа автокоманд

```lua
local goimports_group = vim.api.nvim_create_augroup("go_auto_imports", { clear = true })
```

**Зачем:** Группировка автокоманд для удобного управления (можно очистить все сразу)

##### Функция organize_go_imports

```lua
local function organize_go_imports(bufnr)
```

**Алгоритм работы:**

**Шаг 1: Получение клиента**
```lua
local clients = vim.lsp.get_clients { bufnr = bufnr, name = "gopls" }
if #clients == 0 then
  return
end
```
Находит подключенный gopls для текущего буфера

**Шаг 2: Определение диапазона**
```lua
local last_line_nr = vim.api.nvim_buf_line_count(bufnr)
local last_line = vim.api.nvim_buf_get_lines(bufnr, last_line_nr - 1, last_line_nr, false)[1] or ""
```
Получает количество строк и последнюю строку файла

**Шаг 3: Создание параметров запроса**
```lua
params = {
  textDocument = vim.lsp.util.make_text_document_params(bufnr),
  range = {
    start = { line = 0, character = 0 },
    ["end"] = {
      line = math.max(last_line_nr - 1, 0),
      character = #last_line,
    },
  },
}
```

**Шаг 4: Контекст (только organizeImports)**
```lua
params.context = {
  only = { "source.organizeImports" },
  diagnostics = vim.diagnostic.get(bufnr),
}
```

**Шаг 5: Отправка запроса**
```lua
local result = client:request_sync("textDocument/codeAction", params, 1000, bufnr)
if not result or not result.result then
  return
end
```
- `request_sync` — синхронный запрос (ждёт ответ)
- `1000` — таймаут 1000мс

**Шаг 6: Применение изменений**
```lua
for _, action in ipairs(result.result) do
  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
  end

  if action.command then
    client:exec_cmd(action.command, { bufnr = bufnr })
  end
end
```

**Что делает:**
- Добавляет недостающие импорты
- Удаляет неиспользуемые импорты
- Сортирует импорты (группировка stdlib → external)

##### Автокоманда: при сохранении

```lua
vim.api.nvim_create_autocmd("BufWritePre", {
  group = goimports_group,
  pattern = "*.go",
  callback = function(args)
    organize_go_imports(args.buf)
  end,
})
```

**Когда срабатывает:** Перед записью файла `*.go` (`BufWritePre`)

**Результат:** При сохранении Go-файла импорты автоматически организуются

##### Автокоманда: при подключении LSP

```lua
vim.api.nvim_create_autocmd("LspAttach", {
  group = goimports_group,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "gopls" then
      return
    end

    vim.keymap.set("n", "<leader>gi", function()
      organize_go_imports(args.buf)
    end, {
      buffer = args.buf,
      desc = "Go organize imports",
    })
  end,
})
```

**Что делает:**
1. Проверяет что подключился именно gopls
2. Создаёт маппинг `<leader>gi` для ручного запуска организации импортов
3. `buffer = args.buf` — маппинг работает только для текущего буфера

#### 4. Включение LSP

```lua
vim.lsp.enable "gopls"
```

Активирует gopls для файлов Go (автоматически запускает сервер при открытии `.go` файла)

---

## 🐛 Отладчик (configs/dap.lua)

### Полный код
```lua
local dap = require("dap")

-- breakpoint
vim.keymap.set("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })

-- старт / продолжить
vim.keymap.set("n", "<leader>dc", function()
  dap.continue()
end, { desc = "Start / Continue Debug" })

-- открыть debug REPL
vim.keymap.set("n", "<leader>dr", function()
  dap.repl.open()
end, { desc = "Open Debug REPL" })

-- включить / выключить UI
vim.keymap.set("n", "<leader>du", function()
  local ok, dapui = pcall(require, "dapui")
  if ok then
    dapui.toggle()
  end
end, { desc = "Toggle Debug UI" })

-- дебаг теста
vim.keymap.set("n", "<leader>dt", function()
  require("dap-go").debug_test()
end, { desc = "Debug Test" })

-- повтор последнего запуска
vim.keymap.set("n", "<leader>dl", function()
  require("dap-go").debug_last()
end, { desc = "Debug Last Run" })

-- breakpoint значок
vim.fn.sign_define("DapBreakpoint", {
  text = "🔴",
  texthl = "DiagnosticError",
})
```

### Подробное описание

#### 1. Инициализация DAP

```lua
local dap = require("dap")
```

**DAP** = Debug Adapter Protocol — протокол для отладки кода (аналог LSP для отладки)

#### 2. Клавиатурные маппинги

##### Toggle Breakpoint

```lua
map("n", "<leader>db", function()
  dap.toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
```

**Что делает:**
- Ставит точку останова на текущей строке
- Если уже стоит — снимает
- Точка отображается как 🔴 в signcolumn

##### Start / Continue

```lua
map("n", "<leader>dc", function()
  dap.continue()
end, { desc = "Start / Continue Debug" })
```

**Что делает:**
- Если отладка не запущена — запускает
- Если на breakpoint — продолжает до следующего
- Если не на breakpoint — запускает с начала

##### Open Debug REPL

```lua
map("n", "<leader>dr", function()
  dap.repl.open()
end, { desc = "Open Debug REPL" })
```

**Что такое REPL:**
- Read-Eval-Print Loop
- Интерактивная консоль для выполнения кода
- Можно проверять переменные, вызывать функции
- Работает в контексте отладки

##### Toggle Debug UI

```lua
map("n", "<leader>du", function()
  local ok, dapui = pcall(require, "dapui")
  if ok then
    dapui.toggle()
  end
end, { desc = "Toggle Debug UI" })
```

**Что показывает dapui:**
- Окно переменных (локальные, глобальные)
- Окно стека вызовов (call stack)
- Окно breakpoints (список точек останова)
- Окно консоли (output)

**pcall** — защищённый вызов (не упадёт если плагин не установлен)

##### Debug Test

```lua
map("n", "<leader>dt", function()
  require("dap-go").debug_test()
end, { desc = "Debug Test" })
```

**Что делает:**
- Запускает отладку ближайшего теста
- Для Go — находит функцию `TestXxx` рядом с курсором
- Запускает `go test` с отладчиком Delve

##### Debug Last Run

```lua
map("n", "<leader>dl", function()
  require("dap-go").debug_last()
end, { desc = "Debug Last Run" })
```

**Что делает:**
- Повторяет последний запущенный тест/отладку
- Удобно для итеративной отладки

#### 3. Иконка breakpoint

```lua
vim.fn.sign_define("DapBreakpoint", {
  text = "🔴",
  texthl = "DiagnosticError",
})
```

**Параметры:**

| Параметр | Значение | Описание |
|---------|----------|----------|
| `text` | `🔴` | Символ точки останова (emoji) |
| `texthl` | `DiagnosticError` | Группа подсветки (красный цвет) |

---

## ✨ Форматирование кода (configs/conform.lua)

### Полный код
```lua
local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },

    go = {
      "gofumpt",      -- строгий форматер
      "goimports",    -- автофикс импортов
    }
  },

  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
```

### Подробное описание

#### 1. Форматеры по типам файлов

##### Lua

```lua
lua = { "stylua" }
```

**StyLua** — форматер для Lua:
- Фиксирует отступы
- Выравнивает скобки
- Стандартизирует стиль (циты, пробелы)

##### CSS

```lua
css = { "prettier" }
```

**Prettier** — универсальный форматер:
- Форматирует CSS, SCSS, Less
- Выравнивает свойства
- Управляет пробелами и переносами

##### HTML

```lua
html = { "prettier" }
```

Форматирует HTML-файлы через Prettier

##### Go

```lua
go = {
  "gofumpt",
  "goimports",
}
```

**Порядок выполнения:** Форматеры выполняются **последовательно** в указанном порядке

**1. gofumpt** — строгий форматер (более строгий чем gofmt):
- Убирает лишние пустые строки
- Форматирует отступы
- Выравнивает код
- Требует `go fmt` стиль

**2. goimports** — управление импортами:
- Добавляет недостающие импорты
- Удаляет неиспользуемые
- Сортирует импорты (stdlib → external)

#### 2. Форматирование при сохранении

```lua
format_on_save = {
  timeout_ms = 500,
  lsp_fallback = true,
}
```

**Параметры:**

| Параметр | Значение | Описание |
|---------|----------|----------|
| `timeout_ms` | `500` | Максимальное время на форматирование (мс) |
| `lsp_fallback` | `true` | Если нет форматера — использовать LSP |

**Как работает:**
1. При сохранении файла (`:w`)
2. Запускается форматер для типа файла
3. Если таймаут > 500мс — прерывается
4. Если форматера нет — используется LSP (если поддерживает `textDocument/formatting`)

---

## 🔌 Плагины (plugins/init.lua)

### Полный код
```lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("configs.lsp")
    end,
  },
  {
    "stevearc/dressing.nvim",
    lazy = false,
    opts = {},
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("configs.conform")
    end,
  },

  {
    "mfussenegger/nvim-dap",
    config = function()
      require("configs.dap")
    end,
  },

  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("dap-go").setup()
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}

      local parsers = {
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "yaml",
      }

      for _, parser in ipairs(parsers) do
        if not vim.tbl_contains(opts.ensure_installed, parser) then
          table.insert(opts.ensure_installed, parser)
        end
      end
    end,
  },
}
```

### Подробное описание

#### 1. nvim-lspconfig

```lua
{
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("configs.lsp")
  end,
}
```

**Параметры:**

| Параметр | Значение | Описание |
|---------|----------|----------|
| `event` | `BufReadPre, BufNewFile` | Загружается при открытии/создании файла |
| `config` | `require("configs.lsp")` | Вызывает конфигурацию LSP |

**Что делает:**
- Конфигурация языковых серверов
- Интеграция с Neovim LSP
- Поддержка 50+ языковых серверов

#### 2. dressing.nvim

```lua
{
  "stevearc/dressing.nvim",
  lazy = false,
  opts = {},
}
```

**Что делает:**
- Улучшает стандартные UI элементы Neovim
- Делает более красивыми:
  - `vim.ui.select()` — выбор из списка
  - `vim.ui.input()` — ввод значения
- Добавляет интеграцию с Telescope

**lazy = false** — загружается сразу (не откладывается)

#### 3. conform.nvim

```lua
{
  "stevearc/conform.nvim",
  event = "BufWritePre",
  config = function()
    require("configs.conform")
  end,
}
```

**Что делает:**
- Форматирование кода
- Поддержка 50+ форматеров
- Форматирование при сохранении

**event = "BufWritePre"** — загружается перед сохранением файла

#### 4. nvim-dap

```lua
{
  "mfussenegger/nvim-dap",
  config = function()
    require("configs.dap")
  end,
}
```

**Что делает:**
- Debug Adapter Protocol клиент
- Отладка кода
- Точки останова, пошаговое выполнение
- Просмотр переменных

#### 5. nvim-dap-go

```lua
{
  "leoluz/nvim-dap-go",
  ft = "go",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    require("dap-go").setup()
  end,
}
```

**Параметры:**

| Параметр | Значение | Описание |
|---------|----------|----------|
| `ft` | `go` | Загружается только для Go файлов |
| `dependencies` | `nvim-dap` | Требует установленный nvim-dap |

**Что делает:**
- Интеграция DAP для Go
- Отладка тестов (`debug_test()`)
- Повтор последнего запуска (`debug_last()`)
- Delve интеграция

#### 6. nvim-dap-ui

```lua
{
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end

    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end

    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end,
}
```

**Что делает:**
- UI для отладчика
- Показывает переменные, стек, breakpoints

**Логика работы:**
1. **При инициализации DAP** (`event_initialized`) → открыть UI
2. **Перед завершением** (`event_terminated`) → закрыть UI
3. **После выхода** (`event_exited`) → закрыть UI

**Зависимости:**
- `nvim-dap` — основной клиент отладки
- `nvim-nio` — библиотека для асинхронности (Neovim I/O)

#### 7. nvim-dap-virtual-text

```lua
{
  "theHamsta/nvim-dap-virtual-text",
  dependencies = { "mfussenegger/nvim-dap" },
  config = function()
    require("nvim-dap-virtual-text").setup()
  end,
}
```

**Что делает:**
- Показывает значения переменных прямо в коде
- Виртуальный текст рядом со строками

**Пример:**
```go
x := 5      // ← x = 5 (виртуальный текст)
y := 10     // ← y = 10
z := x + y  // ← z = 15
```

#### 8. render-markdown.nvim

```lua
{
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {},
}
```

**Что делает:**
- Рендерит Markdown прямо внутри окна Neovim
- Улучшает отображение заголовков, списков, чекбоксов, таблиц и callouts
- Не открывает внешний браузер и не требует отдельного preview-окна

**Почему `ft = { "markdown" }`:**
- Плагин загружается только при открытии `.md` файлов
- Это уменьшает лишнюю нагрузку при обычной работе с кодом

**Как пользоваться:**
- Открыть любой `.md` файл
- В normal mode видеть отрендеренный Markdown
- При редактировании строки работать с обычным исходным Markdown
- При необходимости использовать команды:
  - `:RenderMarkdown enable`
  - `:RenderMarkdown disable`
  - `:RenderMarkdown toggle`
  - `:RenderMarkdown preview`

#### 9. nvim-treesitter override

```lua
{
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}

    local parsers = {
      "html",
      "css",
      "markdown",
      "markdown_inline",
      "yaml",
    }

    for _, parser in ipairs(parsers) do
      if not vim.tbl_contains(opts.ensure_installed, parser) then
        table.insert(opts.ensure_installed, parser)
      end
    end
  end,
}
```

**Что делает:**
- Не переопределяет дефолтный список NvChad, а безопасно расширяет его
- Гарантирует, что Markdown-рендерер получит обязательные grammar-файлы

**Зачем нужны парсеры:**
- `markdown` и `markdown_inline` — базовый разбор Markdown
- `html` — HTML-комментарии и встроенные HTML-блоки
- `yaml` — frontmatter вида `--- title: ... ---`

---

## 📖 Справочник клавишных комбинаций

> ⚠️ **Важно:** Ниже перечислены **только реальные хоткеи** из этой конфигурации. Стандартные хоткеи NvChad см. в [KEYBINDINGS_REFERENCE.md](./KEYBINDINGS_REFERENCE.md).

### Пользовательские хоткеи (из этой конфигурации)

| Клавиши | Режим | Файл | Описание |
|---------|-------|------|----------|
| `;` | Normal | `mappings.lua` | Вход в командный режим |
| `fd` | Insert | `mappings.lua` | Выход из режима вставки |
| `<leader>h` | Normal | `mappings.lua` | Открыть Dashboard |
| `<leader>gt` | Normal | `mappings.lua` | Git status (Telescope) |
| `<leader>cm` | Normal | `mappings.lua` | Git commits (Telescope) |
| `<leader>gi` | Normal (Go) | `configs/lsp.lua` | Организовать импорты |
| `<leader>db` | Normal | `configs/dap.lua` | Toggle breakpoint |
| `<leader>dc` | Normal | `configs/dap.lua` | Continue debug |
| `<leader>dr` | Normal | `configs/dap.lua` | Open REPL |
| `<leader>du` | Normal | `configs/dap.lua` | Toggle Debug UI |
| `<leader>dt` | Normal (Go) | `configs/dap.lua` | Debug test |
| `<leader>dl` | Normal (Go) | `configs/dap.lua` | Debug last run |

---

## 🔧 Требования для работы

### Для Go-разработки

```bash
# Языковой сервер
go install golang.org/x/tools/gopls@latest

# Форматер
go install mvdan.cc/gofumpt@latest

# Управление импортами
go install golang.org/x/tools/cmd/goimports@latest

# Отладчик
go install github.com/go-delve/delve/cmd/dlv@latest
```

### Для форматирования других языков

```bash
# Lua
cargo install stylua

# CSS/HTML
npm install -g prettier
```

---

*Документация создана для конфигурации NvChad v2.5*

**Последнее обновление:** Апрель 2026
