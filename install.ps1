# Установка конфига Neovim (Windows, PowerShell 5.1 или 7).
#   irm https://raw.githubusercontent.com/Alt-Entros/nvim/main/install.ps1 | iex
# Другой репозиторий/ветка:
#   $env:NVIM_CONFIG_REPO = "https://github.com/you/nvim.git"; irm .../install.ps1 | iex

$ErrorActionPreference = "Stop"

$Repo   = if ($env:NVIM_CONFIG_REPO)   { $env:NVIM_CONFIG_REPO }   else { "https://github.com/Alt-Entros/nvim.git" }
$Branch = if ($env:NVIM_CONFIG_BRANCH) { $env:NVIM_CONFIG_BRANCH } else { "main" }
$App    = if ($env:NVIM_APPNAME)       { $env:NVIM_APPNAME }       else { "nvim" }
$Config = Join-Path $env:LOCALAPPDATA $App
$Data   = Join-Path $env:LOCALAPPDATA "$App-data"

function Say($m)  { Write-Host "==> $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "!!  $m" -ForegroundColor Yellow }
function Has($c)  { [bool](Get-Command $c -ErrorAction SilentlyContinue) }

# ── Обязательное ───────────────────────────────────────────────────
if (-not (Has "git"))  { throw "Нужен git: winget install Git.Git" }
if (-not (Has "nvim")) { throw "Нужен Neovim 0.11+: winget install Neovim.Neovim (потом перезапусти терминал)" }

# ── Бэкап старого конфига и данных ─────────────────────────────────
$Stamp = Get-Date -Format "yyyyMMdd-HHmmss"
foreach ($dir in @($Config, $Data)) {
  if (Test-Path $dir) {
    Move-Item $dir "$dir.bak.$Stamp"
    Say "Старое: $dir -> $dir.bak.$Stamp"
  }
}

# ── Клонирование и установка плагинов ──────────────────────────────
Say "Клонирую $Repo ($Branch) -> $Config"
git clone --quiet --depth 1 --branch $Branch $Repo $Config
if ($LASTEXITCODE -ne 0) { throw "git clone завершился с ошибкой" }

Say "Ставлю плагины (версии из lazy-lock.json)..."
nvim --headless "+Lazy! restore" +qa *> $null
if ($LASTEXITCODE -ne 0) { Warn "Lazy завершился с ошибкой — откроется при запуске" }

# ── Проверка внешних утилит ────────────────────────────────────────
$need = [ordered]@{
  "rg"      = "BurntSushi.ripgrep.MSVC"
  "fd"      = "sharkdp.fd"
  "lazygit" = "JesseDuffield.lazygit"
  "node"    = "OpenJS.NodeJS.LTS"
  "python"  = "Python.Python.3.13"
  "pwsh"    = "Microsoft.PowerShell"
}
$missing = @()
foreach ($c in $need.Keys) { if (-not (Has $c)) { $missing += $need[$c] } }
if (-not ((Has "clang") -or (Has "gcc") -or (Has "cl"))) { $missing += "LLVM.LLVM" }

if ($missing.Count -gt 0) {
  Warn "Не хватает утилит. Поставь одной командой:"
  Warn ("winget install " + ($missing -join " "))
  Warn "Компилятор C (LLVM) нужен для подсветки treesitter — без него её не будет."
}

Say "Готово. Запусти nvim — Mason в фоне поставит LSP и форматтеры (прогресс: :Mason)."
Say "Шпаргалка по клавишам: $Config\README.md или <пробел> f k внутри nvim."
