# Конфиг Neovim (0.12+)

Свой конфиг вместо NvChad: lazy.nvim, LSP ставятся и запускаются сами через Mason,
blink.cmp, conform (формат при сохранении), telescope, nvim-tree, toggleterm,
пикер тем как в NvChad, стартовая страница, markdown-заметки как в Obsidian.

## Установка

### Одной командой

**macOS / Linux:**
```sh
curl -fsSL https://raw.githubusercontent.com/Alt-Entros/nvim/main/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Alt-Entros/nvim/main/install.ps1 | iex
```

Что делает скрипт:
1. Проверяет git и Neovim 0.11+.
2. Старый конфиг и данные nvim переносит в `*.bak.<дата>` (ничего не удаляет).
3. Клонирует репозиторий в `~/.config/nvim` (Windows: `%LOCALAPPDATA%\nvim`).
4. Ставит плагины на версии из `lazy-lock.json` — у всех одинаковые, проверенные версии.
5. Проверяет внешние утилиты и печатает команду, которой поставить недостающие.

Дальше просто `nvim`: Mason в фоне поставит LSP, форматтеры и tree-sitter CLI
(прогресс — `:Mason`), после этого сами скачаются парсеры подсветки.

**Попробовать, не трогая текущий конфиг** — поставить под другим именем:
```sh
NVIM_APPNAME=nvim-test sh -c "$(curl -fsSL https://raw.githubusercontent.com/Alt-Entros/nvim/main/install.sh)"
NVIM_APPNAME=nvim-test nvim
```

### Обновление

- Плагины: `:Lazy update` внутри nvim.
- Сам конфиг: `git -C ~/.config/nvim pull`, потом `:Lazy restore` (подтянуть версии из нового lock-файла).
- LSP и форматтеры: `:Mason`, затем `U`.

### Зависимости

**macOS:**
```sh
brew install ripgrep fd lazygit python node
brew install --cask dotnet-sdk      # для C# (roslyn)
brew install caddy                  # опционально — форматирование Caddyfile
brew install imagemagick            # опционально — jpg/gif/svg в markdown (PNG видно и без него)
brew install libpq mysql-client && brew link --force libpq mysql-client  # опционально — psql/mysql для баз данных
xcode-select --install              # make + clang для telescope-fzf-native и парсеров treesitter
```

`python` из brew обязателен: системный Python 3.9 от Apple слишком старый для `ansible-lint`.

Kitty — добавь в `~/.config/kitty/kitty.conf`, иначе Alt-клавиши (терминалы, перенос строк) не работают:

```
macos_option_as_alt yes
```

**Arch Linux:**
```sh
sudo pacman -S neovim git ripgrep fd lazygit nodejs npm python base-devel unzip
```

**Windows:**
```powershell
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC sharkdp.fd JesseDuffield.lazygit
winget install OpenJS.NodeJS.LTS Python.Python.3.13 Microsoft.PowerShell
winget install Microsoft.DotNet.SDK.9                    # C#
winget install LLVM.LLVM                                  # clang — компилятор C для парсеров treesitter и для <leader>rr
```

- **Терминал** — Windows Terminal, шрифт с иконками (Nerd Font, например JetBrainsMono Nerd Font).
- **Компилятор C обязателен**: без него nvim-treesitter не соберёт парсеры (подсветки не будет).
  Подходит clang из LLVM, MinGW-gcc или Visual Studio Build Tools (C++).
- Встроенный терминал и запуск файлов работают через PowerShell 7 (`pwsh`), если он установлен.
- `telescope-fzf-native` без `make` не ставится — это нормально, поиск работает и без него.

## Настройки и язык

Личные настройки — в `lua/user.lua` (он в `.gitignore`, поэтому `git pull` с ним не конфликтует):

```sh
cp ~/.config/nvim/lua/user.example.lua ~/.config/nvim/lua/user.lua
```

```lua
-- lua/user.lua
return {
  language = "ru",            -- язык интерфейса: "en" (по умолчанию) | "ru"
  theme = "catppuccin-mocha", -- тема по умолчанию
  transparent = false,        -- прозрачный фон
  format_on_save = false,     -- формат при сохранении
}
```

Указывай только то, что меняешь, остальное возьмётся из `lua/config/settings.lua`.
После смены языка перезапусти nvim.

- Тема и прозрачность, выбранные через `<leader>th` / `<leader>ut`, запоминаются и
  важнее значений из `user.lua`. Сбросить выбор: удалить `~/.local/share/nvim/theme.json`.
- Язык переводит описания клавиш (which-key, `<leader>fk`), стартовую страницу и уведомления.
  Тексты самих плагинов (Lazy, Mason, Telescope) остаются на английском.
- **Новый язык:** скопируй `lua/config/locales/ru.lua` в `lua/config/locales/<код>.lua`,
  переведи значения и укажи `language = "<код>"`. Непереведённое останется на английском.
- **Новая строка в конфиге:** пиши по-английски через `t("Text")`
  (`local t = require("config.i18n").t`) и добавь перевод в `locales/ru.lua`.

## Структура

```
init.lua
lua/user.example.lua — пример личных настроек (копировать в lua/user.lua)
lua/config/
  settings.lua    — настройки по умолчанию (язык, тема, прозрачность, формат)
  i18n.lua        — переводы: t("English text") → текст на выбранном языке
  locales/ru.lua  — русский перевод
  options.lua     — опции, системный буфер обмена (+ OSC 52 по SSH)
  keymaps.lua     — общие клавиши
  autocmds.lua    — автокоманды (отступы по языкам, подсветка yank…)
  filetypes.lua   — распознавание compose / ansible / nginx / Caddyfile
  theme.lua       — пикер тем + прозрачность, сохранение выбора
  lazy.lua        — менеджер плагинов
lua/plugins/
  lsp.lua         — Mason, список LSP и инструментов, настройки серверов, LSP-клавиши
  completion.lua  — blink.cmp, автоскобки
  format-lint.lua — conform, nvim-lint
  telescope.lua   — telescope и его клавиши
  explorer.lua    — nvim-tree
  terminal.lua    — терминалы, lazygit, запуск файла
  treesitter.lua  — подсветка
  ui.lua          — which-key, lualine, bufferline, gitsigns, trouble, отступы, TODO
  colorschemes.lua— темы
  dashboard.lua   — стартовая страница
  markdown.lua    — рендер markdown, картинки, клавиши заметок
  database.lua    — базы данных (vim-dadbod-ui), запуск запросов
lua/config/markdown.lua — переходы по [[ссылкам]], обратные ссылки, чекбоксы
```

**Добавить язык:** имя LSP — в `servers` в `lsp.lua`, форматтер — в `tools` и в
`formatters_by_ft` в `format-lint.lua`, парсер — в `parsers` в `treesitter.lua`.

## Языки

| Язык | LSP | Формат / линт |
|---|---|---|
| C / C++ | clangd (+ clang-tidy) | clang-format |
| C# | roslyn | csharpier |
| Python | basedpyright + ruff | ruff (формат + сортировка импортов) |
| Dockerfile | dockerls | hadolint |
| docker-compose | docker_compose_language_service + yamlls | prettier |
| YAML / JSON | yamlls / jsonls + SchemaStore | prettier |
| Ansible | ansiblels (+ ansible-lint) | prettier |
| nginx | nginx_language_server | — |
| Caddyfile | — (только подсветка) | `caddy fmt` |
| bash / TOML | bashls (+ shellcheck) / taplo | shfmt / taplo |
| Lua | lua_ls + lazydev | stylua |
| Vue / TS / HTML / CSS | vtsls + vue_ls, html, cssls, tailwindcss, eslint | prettier |
| Markdown | markdown_oxide | prettier |

**C/C++:** clangd нужен `compile_commands.json` в корне проекта, иначе он не найдёт
инклуды. CMake: `cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -s build/compile_commands.json .`;
Make: `bear -- make` (`brew install bear`). Для одиночных файлов работает и без него.

**Ansible:** файлы распознаются по пути (`playbooks/`, `roles/*/tasks/`, `group_vars/`,
`host_vars/`, `site.yml`, `playbook.yml`). Если твоя раскладка другая — допиши
шаблон в `lua/config/filetypes.lua`.

## Шорткаты

`<leader>` = пробел. **Нажми пробел и подожди** — which-key покажет меню.
Поиск по всем клавишам: `<leader>fk`.

### Основное
| Клавиша | Действие |
|---|---|
| `;` | `:` (командный режим) |
| `jk` | выйти в normal (insert) |
| `<C-s>` | сохранить |
| `<Esc>` | убрать подсветку поиска |
| `<leader>/` | закомментировать строку / выделение |
| `<C-h/j/k/l>` | переход между окнами |
| `<C-стрелки>` | размер окна |
| `<leader>sv` / `<leader>sh` | вертикальный / горизонтальный сплит |
| `<A-j>` / `<A-k>` | перенести строку / выделение вниз / вверх |
| `<Tab>` / `<S-Tab>` | следующий / предыдущий буфер |
| `<leader>x` / `<leader>X` | закрыть буфер / закрыть остальные |
| `<leader>bj` | выбрать буфер по букве |
| `<leader>L` / `<leader>M` | Lazy / Mason |

### Буфер обмена
`y`, `p`, `d` работают с системным буфером macOS. По SSH копирование идёт через OSC 52
прямо в буфер Мака.
| Клавиша | Действие |
|---|---|
| `<leader>p` (visual) | вставить поверх выделения, не затирая буфер |
| `<leader>D` | удалить без копирования |
| `x` | удалить символ без копирования |
| `<C-c>` | скопировать весь файл |

### Дерево файлов (nvim-tree)
| Клавиша | Действие |
|---|---|
| `<C-n>` | открыть / закрыть дерево |
| `<leader>e` | фокус на дерево |
| В дереве: `a` / `d` / `r` / `x` / `c` / `p` | создать / удалить / переименовать / вырезать / копировать / вставить |
| В дереве: `g?` | все клавиши дерева |

### Поиск (telescope)
| Клавиша | Действие |
|---|---|
| `<leader>ff` | файлы |
| `<leader>fa` | все файлы, включая скрытые и .gitignore |
| `<leader>fw` | поиск по тексту (live grep) |
| `<leader>fW` | grep слова под курсором / выделения |
| `<leader>fz` | поиск в текущем файле |
| `<leader>fb`, `<leader><leader>` | открытые буферы |
| `<leader>fo` / `<leader>fO` | недавние файлы (проект / все) |
| `<leader>fr` | вернуться к последнему поиску |
| `<leader>fs` / `<leader>fS` | символы файла / проекта (LSP) |
| `<leader>fd` / `<leader>fD` | ошибки файла / проекта |
| `<leader>fk` | **шорткаты** |
| `<leader>fh` / `<leader>fc` | справка / команды |
| `<leader>ft` | TODO/FIXME в проекте |
| `<leader>fn` | файлы этого конфига |
| `<leader>gs` / `<leader>gc` / `<leader>gB` | git: изменения / коммиты / ветки |

Внутри telescope: `<C-j>/<C-k>` — вверх/вниз, `<Esc>` — закрыть,
`<C-v>` / `<C-s>` — открыть в вертикальном/горизонтальном сплите,
`<C-q>` — всё в quickfix, `<C-p>` — скрыть превью, `<C-f>/<C-b>` — скролл превью.

### LSP
| Клавиша | Действие |
|---|---|
| `K` | документация |
| `gd` / `gD` | определение / объявление |
| `gR` | где используется |
| `gI` / `gy` | реализации / определение типа |
| `<leader>la` (или `gra`) | code action |
| `<leader>lr` (или `grn`) | переименовать |
| `<leader>lf` | отформатировать |
| `<leader>lk` | сигнатура функции |
| `<leader>lh` | inlay hints вкл/выкл |
| `<leader>lo` | C/C++: переключить .h ⇄ .c/.cpp |
| `<leader>li` / `<leader>lR` | инфо / перезапуск LSP |

### Ошибки
| Клавиша | Действие |
|---|---|
| `]d` / `[d` | следующая / предыдущая ошибка |
| `gl` / `<leader>dl` | ошибка под курсором во всплывающем окне |
| `<leader>dd` / `<leader>db` | список ошибок проекта / файла (Trouble) |
| `<leader>ds` | структура файла |
| `<leader>ul` | показывать ошибку строкой под кодом (вместо текста справа) |
| `<leader>ud` | диагностика вкл/выкл |

### Автодополнение
| Клавиша | Действие |
|---|---|
| `<Enter>` | принять |
| `<Tab>` / `<S-Tab>` | следующий / предыдущий вариант, прыжки по сниппету |
| `<C-Space>` | открыть меню вручную |
| `<C-e>` | закрыть меню |
| `<C-k>` | показать / скрыть сигнатуру |

### Терминал
| Клавиша | Действие |
|---|---|
| `<C-\>`, `<A-i>`, `<leader>tf` | плавающий терминал |
| `<A-h>`, `<leader>tb` | терминал снизу |
| `<A-v>`, `<leader>tv` | терминал сбоку |
| `<leader>gg`, `<leader>tg` | lazygit |
| `<leader>rr` | **запустить текущий файл** (C/C++ — gcc/g++, Python, C# — dotnet run…) |
| `<leader>tl` | отправить строку / выделение в нижний терминал |
| `<leader>ta` | выбрать терминал из списка |
| В терминале: `<C-x>` или `<Esc><Esc>` | выйти в normal-режим |
| В нижнем/боковом: `<C-h/j/k/l>` | перейти в другое окно |

Это три независимых терминала, у каждого сохраняется своя сессия.

### Git
| Клавиша | Действие |
|---|---|
| `]h` / `[h` | следующее / предыдущее изменение |
| `<leader>hp` | показать изменение |
| `<leader>hr` / `<leader>hs` | откатить / stage изменения |
| `<leader>hb` | blame строки |
| `<leader>hd` | diff файла |

### Markdown / заметки (как Obsidian)
Markdown рендерится прямо в буфере: заголовки, списки, чекбоксы, таблицы, код,
callout'ы `> [!note]`, картинки `![](img.png)` / `![[img.png]]` (в kitty, WezTerm, Ghostty).
На строке с курсором виден исходный текст — как Live Preview в Obsidian.

Хранилище (vault) — ближайшая папка вверх с `.obsidian`, `.moxide.toml` или `.git`,
иначе папка файла. Так что можно открыть существующее хранилище Obsidian: `cd ~/Notes && nvim`.

| Клавиша | Действие |
|---|---|
| `<Enter>` / `gf` | открыть ссылку под курсором: `[[заметка]]`, `[[заметка#Заголовок\|текст]]`, `[текст](файл.md)`, URL; на чекбоксе — отметить |
| `<C-o>` | вернуться назад |
| `[[` (insert) | автодополнение заметок и заголовков |
| `gR` | где упоминается заголовок / тег под курсором (LSP) |
| `<leader>mb` | обратные ссылки — какие заметки ссылаются на эту |
| `<leader>mf` / `<leader>mg` | найти заметку / поиск по тексту заметок |
| `<leader>mt` | все `#теги` хранилища |
| `<leader>md` | заметка на сегодня (`:LspToday`, `:LspTomorrow`, `:LspYesterday`) |
| `<leader>mc` | чекбокс `[ ]` ⇄ `[x]` |
| `<leader>mo` (или `gO`) | оглавление файла |
| `<leader>mr` | рендер вкл/выкл (показать исходный markdown) |

Ссылка на несуществующую заметку открывает новый пустой файл в корне хранилища —
он появится на диске после сохранения.

### Базы данных (как Database в GoLand)
vim-dadbod-ui: слева панель подключений → схемы → таблицы (колонки, индексы, ключи),
консоли запросов, результат в окне снизу, автодополнение таблиц и колонок.
Нужен консольный клиент базы: `psql`, `mysql`, `sqlite3` (есть в macOS), `sqlcmd`, `mongosh`, `redis-cli`.

| Клавиша | Действие |
|---|---|
| `<leader>SS` | **панель баз данных** |
| `<leader>Sa` | добавить подключение (сохраняется в `~/.local/share/db_ui/connections.json`) |
| `<C-Enter>` / `<leader>Se` | выполнить запрос под курсором (до пустых строк) / выделение |
| `<leader>SE` | выполнить весь файл |
| `<leader>Sb` | привязать обычный `.sql`-файл к базе (при первом запуске спросит сам) |
| `<leader>Ss` | сохранить консоль как запрос (Saved queries) |
| `<leader>Sp` | значения параметров `:name` в запросе |
| `<leader>Sr` / `<leader>Si` | переименовать консоль / время последнего запроса |
| В панели: `o`/`<Enter>` | раскрыть; на таблице — меню (List, Columns, Indexes…) |
| В панели: `A` / `R` / `d` / `r` / `H` / `q` | добавить / обновить / удалить / переименовать / подробности / закрыть |

В отличие от GoLand, сохранение файла запрос **не** выполняет.

Подключения можно задать и в `lua/user.lua`, и через переменные окружения или `.env` (`DB_UI_DEV=postgres://…`):
```lua
databases = {
  dev = "postgres://user:password@localhost:5432/app",
  shop = "mysql://root@127.0.0.1:3306/shop",
  local_db = "sqlite:" .. vim.fn.expand("~/data/app.db"),
},
```
Пароль из URL хранится открытым текстом, поэтому в `user.lua` (он в `.gitignore`) или в `.env`, но не в git.

Клиенты: macOS — `brew install libpq mysql-client && brew link --force libpq mysql-client`;
Arch — `sudo pacman -S postgresql mariadb-clients sqlite`.

### Темы и интерфейс
| Клавиша | Действие |
|---|---|
| `<leader>th` | **выбрать тему** (с живым превью, сохраняется) |
| `<leader>ut` | прозрачный фон вкл/выкл (сохраняется) |
| `<leader>uf` | формат при сохранении вкл/выкл |
| `<leader>uw` / `<leader>un` | перенос строк / относительные номера |

Новая тема: добавь репозиторий в `lua/plugins/colorschemes.lua`, и она появится в `<leader>th`.
