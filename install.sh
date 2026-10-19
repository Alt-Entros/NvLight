#!/usr/bin/env sh
# Установка конфига Neovim (macOS / Linux).
#   curl -fsSL https://raw.githubusercontent.com/Alt-Entros/nvim/main/install.sh | sh
# Другой репозиторий/ветка:
#   NVIM_CONFIG_REPO=https://github.com/you/nvim.git NVIM_CONFIG_BRANCH=dev sh install.sh
set -eu

REPO="${NVIM_CONFIG_REPO:-https://github.com/Alt-Entros/nvim.git}"
BRANCH="${NVIM_CONFIG_BRANCH:-main}"
APP="${NVIM_APPNAME:-nvim}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/$APP"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/$APP"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/$APP"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/$APP"

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# ── Обязательное ───────────────────────────────────────────────────
command -v git >/dev/null 2>&1 || die "Нужен git"
command -v nvim >/dev/null 2>&1 || die "Нужен Neovim 0.11+ (macOS: brew install neovim, Arch: pacman -S neovim)"

nvim --headless -c 'lua if vim.fn.has("nvim-0.11") == 0 then os.exit(1) end' -c 'qa' 2>/dev/null \
  || die "Нужен Neovim 0.11 или новее, сейчас: $(nvim --version | head -1)"

# ── Бэкап старого конфига и данных ─────────────────────────────────
STAMP=$(date +%Y%m%d-%H%M%S)
for dir in "$CONFIG" "$DATA" "$STATE" "$CACHE"; do
  if [ -e "$dir" ]; then
    mv "$dir" "$dir.bak.$STAMP"
    say "Старое: $dir → $dir.bak.$STAMP"
  fi
done

# ── Клонирование и установка плагинов ──────────────────────────────
say "Клонирую $REPO ($BRANCH) → $CONFIG"
git clone --quiet --depth 1 --branch "$BRANCH" "$REPO" "$CONFIG"

say "Ставлю плагины (версии из lazy-lock.json)…"
nvim --headless "+Lazy! restore" +qa </dev/null >/dev/null 2>&1 || warn "Lazy завершился с ошибкой — откроется при запуске"

# ── Проверка внешних утилит ────────────────────────────────────────
missing=""
for c in rg fd lazygit node python3 make; do
  command -v "$c" >/dev/null 2>&1 || missing="$missing $c"
done
command -v cc >/dev/null 2>&1 || command -v clang >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1 \
  || missing="$missing компилятор-C"

if [ -n "$missing" ]; then
  warn "Не найдено:$missing"
  case "$(uname -s)" in
    Darwin) warn "Поставь: brew install ripgrep fd lazygit node python  (компилятор: xcode-select --install)" ;;
    Linux)  warn "Arch: sudo pacman -S ripgrep fd lazygit nodejs python base-devel" ;;
  esac
fi

say "Готово. Запусти nvim — Mason в фоне поставит LSP и форматтеры (прогресс: :Mason)."
say "Шпаргалка по клавишам: $CONFIG/README.md или <пробел> f k внутри nvim."
