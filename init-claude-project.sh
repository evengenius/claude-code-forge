#!/usr/bin/env bash
# ============================================================================
# CLAUDE CODE PROJECT BOOTSTRAP v2.0
# Полная инициализация проекта по методологии структурированной разработки
# с Claude Code (VSCode + Pro subscription)
#
# Использование:
#   chmod +x init-claude-project.sh
#   ./init-claude-project.sh [имя-проекта]
#
# Или с интерактивным вводом:
#   ./init-claude-project.sh
# ============================================================================

set -euo pipefail

# ── Проверка зависимостей ──────────────────────────────────────────────────
require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: требуется команда '$1', не найдена в PATH" >&2
    exit 1
  fi
}

require_cmd git
require_cmd python3
require_cmd grep

# jq нужен для хуков Claude Code (auto-format, защита от опасных команд).
# Если не установлен — настройка не падает, но в финале выводится предупреждение.
JQ_AVAILABLE=1
if ! command -v jq >/dev/null 2>&1; then
  JQ_AVAILABLE=0
fi

# ── Цвета и форматирование ──────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

print_header() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}  ${BOLD}CLAUDE CODE PROJECT BOOTSTRAP${NC}                               ${CYAN}║${NC}"
  echo -e "${CYAN}║${NC}  ${DIM}Structured Development Methodology v2.0${NC}                     ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_step() {
  echo -e "${GREEN}[✓]${NC} ${BOLD}$1${NC}"
}

print_substep() {
  echo -e "    ${DIM}└─${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
  echo -e "${RED}[✗]${NC} $1"
}

# ── Интерактивный ввод параметров ────────────────────────────────────────────

print_header

# Имя проекта
if [ -n "${1:-}" ]; then
  PROJECT_NAME="$1"
else
  echo -e "${BOLD}Введите имя проекта:${NC}"
  read -r PROJECT_NAME
fi

if [ -z "$PROJECT_NAME" ]; then
  print_error "Имя проекта не может быть пустым"
  exit 1
fi

# Валидация: только латинские буквы, цифры, точка, дефис, подчёркивание.
# Исключает path traversal, пробелы, shell-метасимволы.
if ! printf '%s' "$PROJECT_NAME" | grep -qE '^[A-Za-z0-9][A-Za-z0-9._-]*$'; then
  print_error "Недопустимое имя проекта: '$PROJECT_NAME'"
  print_error "Допустимы только латинские буквы, цифры, точка, дефис, подчёркивание (первый символ — буква или цифра)."
  exit 1
fi

# Защита от перезаписи существующей директории/файла.
if [ -e "$PROJECT_NAME" ]; then
  print_error "Путь '$PROJECT_NAME' уже существует — отказ от перезаписи."
  exit 1
fi

echo -e "${BOLD}Краткое описание проекта (1-2 предложения):${NC}"
read -r PROJECT_DESC
PROJECT_DESC="${PROJECT_DESC:-Описание проекта}"

echo ""
echo -e "${BOLD}Выберите тех-стек:${NC}"
echo "  1) Next.js + TypeScript + Prisma + PostgreSQL"
echo "  2) React + TypeScript + Vite"
echo "  3) Node.js + Express + TypeScript"
echo "  4) Python + FastAPI"
echo "  5) Кастомный (ввести вручную)"
read -r STACK_CHOICE

case "${STACK_CHOICE:-1}" in
  1)
    TECH_STACK="Next.js 15 (App Router), TypeScript 5.x, Prisma ORM, PostgreSQL, Tailwind CSS 4, shadcn/ui"
    TEST_FRAMEWORK="Vitest + Testing Library"
    LINT_CMD="npx eslint . --fix && npx prettier --write ."
    TEST_CMD="npx vitest run"
    BUILD_CMD="npm run build"
    DEV_CMD="npm run dev"
    FORMAT_CMD="npx prettier --write"
    LINT_FILE_CMD="npx eslint --fix"
    PKG_MANAGER="npm"
    ;;
  2)
    TECH_STACK="React 19, TypeScript 5.x, Vite, Tailwind CSS 4"
    TEST_FRAMEWORK="Vitest + Testing Library"
    LINT_CMD="npx eslint . --fix && npx prettier --write ."
    TEST_CMD="npx vitest run"
    BUILD_CMD="npm run build"
    DEV_CMD="npm run dev"
    FORMAT_CMD="npx prettier --write"
    LINT_FILE_CMD="npx eslint --fix"
    PKG_MANAGER="npm"
    ;;
  3)
    TECH_STACK="Node.js 22, Express 5, TypeScript 5.x, PostgreSQL"
    TEST_FRAMEWORK="Vitest"
    LINT_CMD="npx eslint . --fix && npx prettier --write ."
    TEST_CMD="npx vitest run"
    BUILD_CMD="npx tsc"
    DEV_CMD="npx tsx watch src/index.ts"
    FORMAT_CMD="npx prettier --write"
    LINT_FILE_CMD="npx eslint --fix"
    PKG_MANAGER="npm"
    ;;
  4)
    TECH_STACK="Python 3.12+, FastAPI, SQLAlchemy 2, PostgreSQL, Pydantic v2"
    TEST_FRAMEWORK="pytest + pytest-asyncio"
    LINT_CMD="ruff check --fix . && ruff format ."
    TEST_CMD="pytest"
    BUILD_CMD="echo 'No build step for Python'"
    DEV_CMD="uvicorn app.main:app --reload"
    FORMAT_CMD="ruff format"
    LINT_FILE_CMD="ruff check --fix"
    PKG_MANAGER="pip"
    ;;
  5)
    echo -e "Введите ${BOLD}тех-стек${NC} (через запятую):"
    read -r TECH_STACK
    echo -e "Введите ${BOLD}тест-фреймворк${NC}:"
    read -r TEST_FRAMEWORK
    echo -e "Введите ${BOLD}команду линта${NC}:"
    read -r LINT_CMD
    echo -e "Введите ${BOLD}команду тестов${NC}:"
    read -r TEST_CMD
    echo -e "Введите ${BOLD}команду сборки${NC}:"
    read -r BUILD_CMD
    echo -e "Введите ${BOLD}команду dev-сервера${NC}:"
    read -r DEV_CMD
    FORMAT_CMD="echo 'no formatter configured'"
    LINT_FILE_CMD="echo 'no linter configured'"
    PKG_MANAGER="npm"
    ;;
  *)
    print_error "Неверный выбор"
    exit 1
    ;;
esac

echo ""
echo -e "${BOLD}Уровень методологии:${NC}"
echo "  1) Minimal  — CLAUDE.md + handoff + хуки (соло-проекты, MVP)"
echo "  2) Standard — + memory bank + ADR + TDD + команды (средние проекты)"
echo "  3) Full     — + BMAD-совместимая структура + качественные ворота (enterprise)"
read -r METHOD_LEVEL
METHOD_LEVEL="${METHOD_LEVEL:-2}"

if ! printf '%s' "$METHOD_LEVEL" | grep -qE '^[123]$'; then
  print_error "Уровень методологии должен быть 1, 2 или 3 (введено: '$METHOD_LEVEL')"
  exit 1
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Создаю проект:${NC} $PROJECT_NAME"
echo -e "${BOLD}Стек:${NC} $TECH_STACK"
echo -e "${BOLD}Уровень:${NC} $METHOD_LEVEL"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Создание структуры директорий ────────────────────────────────────────────

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

print_step "Создаю структуру директорий..."

# Базовые директории (все уровни). .claude/commands не создаём — устарели в пользу skills.
mkdir -p .claude/skills
mkdir -p .claude/agents
mkdir -p .claude/rules
mkdir -p .github/workflows
mkdir -p docs
mkdir -p src

# Standard+ директории
if [ "$METHOD_LEVEL" -ge 2 ]; then
  mkdir -p memory-bank
  mkdir -p adr
  mkdir -p _todo
  mkdir -p _done
fi

# Full директории
if [ "$METHOD_LEVEL" -ge 3 ]; then
  mkdir -p .claude/quality-gates
  mkdir -p specs
  mkdir -p .devcontainer
fi

print_substep "Структура директорий создана"

# ══════════════════════════════════════════════════════════════════════════════
# CLAUDE.md — главный файл инструкций
# ══════════════════════════════════════════════════════════════════════════════

print_step "Генерирую CLAUDE.md..."

# Безопасная генерация файлов из шаблонов с переменными.
# Используем python3 (более надёжно для произвольного контента, чем sed).
render_template() {
  # $1 — путь файла; шаблон читается со stdin.
  # Подставляются переменные через os.environ.
  local out="$1"
  PROJECT_NAME="$PROJECT_NAME" \
  PROJECT_DESC="$PROJECT_DESC" \
  TECH_STACK="$TECH_STACK" \
  TEST_FRAMEWORK="$TEST_FRAMEWORK" \
  DEV_CMD="$DEV_CMD" \
  BUILD_CMD="$BUILD_CMD" \
  TEST_CMD="$TEST_CMD" \
  LINT_CMD="$LINT_CMD" \
  python3 -c '
import os, sys
template = sys.stdin.read()
for key in ("PROJECT_NAME","PROJECT_DESC","TECH_STACK","TEST_FRAMEWORK",
            "DEV_CMD","BUILD_CMD","TEST_CMD","LINT_CMD"):
    template = template.replace("{{" + key + "}}", os.environ.get(key, ""))
sys.stdout.write(template)
' > "$out"
}

render_template CLAUDE.md << 'CLAUDE_EOF'
# Project: {{PROJECT_NAME}}

{{PROJECT_DESC}}

## Tech Stack
- {{TECH_STACK}}
- Tests: {{TEST_FRAMEWORK}}

## Build & Run
- `{{DEV_CMD}}` — dev server
- `{{BUILD_CMD}}` — production build
- `{{TEST_CMD}}` — run tests
- `{{LINT_CMD}}` — lint + format

## Architecture
- TODO: Описать архитектуру после первой сессии планирования
- Паттерн: [Repository → Service → Controller / иной]

## Workflow (Anthropic recommended)
1. **Explore** (Plan Mode, Shift+Tab): прочитай связанные файлы без правок
2. **Plan**: составь план реализации, оцени риски и зависимости
3. **Implement**: пиши код по TDD (RED → GREEN → REFACTOR)
4. **Verify**: запусти тесты, сделай скриншоты, проверь результат против критериев
5. **Commit**: conventional commits, маленькие осмысленные коммиты

IMPORTANT: для задач >30 минут или незнакомого кода ВСЕГДА начинай с Plan Mode.
IMPORTANT: предоставляй критерии верификации (тесты, expected output) — это #1 рычаг качества.

## Key Conventions
- ESM modules (import/export), NOT CommonJS
- Файлы тестов: `*.test.ts` / `*.test.py` рядом с тестируемым файлом
- Коммиты: conventional commits (feat:, fix:, refactor:, docs:, test:, chore:)
- Ветки: feature/*, bugfix/*, hotfix/*

## Context Management
- `/clear` между несвязанными задачами (чистый контекст > длинная сессия)
- `/compact <инструкция>` при заполнении контекста 60-80%
- Используй subagents для исследования (не засоряют основной контекст)
- При двух неудачных коррекциях подряд — `/clear` и переформулируй запрос

## Common Gotchas
- TODO: Заполняется итеративно по мере обнаружения проблем

## Reference Documents
@PLANNING.md
@TASKS.md
@docs/ARCHITECTURE.md
CLAUDE_EOF

# Добавить ссылки на memory bank, ADR, правила и subagents для Standard+
if [ "$METHOD_LEVEL" -ge 2 ]; then
  cat >> CLAUDE.md << 'EOF'

## Memory Bank
В начале каждой сессии прочитай (или выполни `/freshstart`):
@memory-bank/projectbrief.md
@memory-bank/activeContext.md
@memory-bank/progress.md
@memory-bank/systemPatterns.md

## Architecture Decision Records
Прочитай файлы в `adr/` для понимания принятых архитектурных решений.

## Project Rules
Дополнительные правила автоматически загружаются из `.claude/rules/`:
- `security.md` — обязательные правила безопасности (применяются ко всем файлам)
- `git.md` — конвенции git (применяются ко всем файлам)
- `testing.md` — правила тестирования (применяются только к тест-файлам через `paths:`)
EOF
fi

print_substep "CLAUDE.md создан"

# ══════════════════════════════════════════════════════════════════════════════
# CLAUDE.local.md — личные настройки
# ══════════════════════════════════════════════════════════════════════════════

print_step "Генерирую CLAUDE.local.md..."

cat > CLAUDE.local.md << 'EOF'
# Personal Settings (не коммитить — в .gitignore)

## Preferences
- Язык комментариев: русский для бизнес-логики, английский для API/public
- При ошибках: обнови CLAUDE.md секцию "Common Gotchas"
- Модель по умолчанию: sonnet для кода, opus для архитектуры

## Local Environment
- OS: Linux / macOS / Windows (WSL)
- Editor: VSCode + Claude Code extension
- Terminal: integrated VSCode terminal
EOF

print_substep "CLAUDE.local.md создан"

# ══════════════════════════════════════════════════════════════════════════════
# .claude/settings.json — permissions + hooks
# ══════════════════════════════════════════════════════════════════════════════

print_step "Настраиваю .claude/settings.json (permissions + hooks)..."

# Генерируем JSON через python3 — избегаем ада экранирования и невалидного JSON.
# Формат хуков (актуальный для Claude Code 2026): events → matcher + hooks: [{type:"command", command:"..."}]
# Хуки получают данные через stdin как JSON, поэтому парсим через jq.
# ВАЖНО: read-only команды (ls, cat, head, tail, grep, find, wc, which, pwd, cd, git log/diff/status/show)
# Claude Code знает встроенно как read-only — их не нужно в allow.
# shellcheck disable=SC2016  # single quotes намеренно: python читает переменные через os.environ
PKG_MANAGER_ENV="$PKG_MANAGER" \
TEST_CMD_ENV="$TEST_CMD" \
DEV_CMD_ENV="$DEV_CMD" \
BUILD_CMD_ENV="$BUILD_CMD" \
LINT_CMD_ENV="$LINT_CMD" \
FORMAT_CMD_ENV="$FORMAT_CMD" \
LINT_FILE_CMD_ENV="$LINT_FILE_CMD" \
python3 -c '
import json, os, shlex

pkg = os.environ["PKG_MANAGER_ENV"]
fmt = os.environ["FORMAT_CMD_ENV"]
lint_file = os.environ["LINT_FILE_CMD_ENV"]

# PostToolUse: auto-format + auto-lint после Edit/Write.
# Источник: https://code.claude.com/docs/en/hooks
post_edit_cmd = (
    "f=\"$(jq -r \x27.tool_input.file_path // empty\x27 2>/dev/null)\"; "
    "if [ -n \"$f\" ] && [ -f \"$f\" ]; then "
    f"  {fmt} \"$f\" >/dev/null 2>&1 || true; "
    f"  {lint_file} \"$f\" >/dev/null 2>&1 || true; "
    "fi; exit 0"
)

# PreToolUse: блокировка опасных команд (exit 2 = block, сообщение идёт в Claude).
# Учтены CVE-2025-54794/54795/59536 (path/command injection в Claude Code wrappers).
danger_regex = (
    # rm -rf / или rm -rf /*
    "(^|[[:space:]])rm[[:space:]]+-rf?[[:space:]]+/+([[:space:]]|$)"
    # rm -rf ~ или rm -rf ~/
    "|(^|[[:space:]])rm[[:space:]]+-rf?[[:space:]]+~(/|[[:space:]]|$)"
    # rm -rf $HOME
    "|(^|[[:space:]])rm[[:space:]]+-rf?[[:space:]]+\\$HOME"
    # git force push в protected ветки
    "|git[[:space:]]+push[[:space:]]+(--force|-f)([[:space:]]+|[[:space:]]+.*[[:space:]]+)(main|master|prod|production|release)([[:space:]]|$)"
    "|git[[:space:]]+reset[[:space:]]+--hard"
    "|git[[:space:]]+clean[[:space:]]+-fd?"
    # SQL destructive
    "|DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)"
    "|TRUNCATE[[:space:]]+TABLE"
    # curl | sh / wget | sh — стандартная supply-chain атака
    "|(curl|wget)[[:space:]]+[^|]*\\|[[:space:]]*(bash|sh|zsh|python|perl|ruby|node)"
    # chmod 777
    "|chmod[[:space:]]+(-R[[:space:]]+)?777"
    # Запись в системные блочные устройства
    "|>[[:space:]]*/dev/sd[a-z]"
    "|mkfs\\."
    "|dd[[:space:]]+if=.*of=/dev/(sd|nvme)"
)
pre_bash_cmd = (
    "cmd=\"$(jq -r \x27.tool_input.command // empty\x27 2>/dev/null)\"; "
    f"if printf %s \"$cmd\" | grep -qiE {shlex.quote(danger_regex)}; then "
    "  echo \"BLOCKED by Claude Code Forge: destructive command pattern matched\" >&2; "
    "  exit 2; "
    "fi; exit 0"
)

# PreToolUse для Write: блокировка коммита секретов (вспомогательная защита, основная — .gitignore + gitleaks).
# Источник: https://code.claude.com/docs/en/hooks-guide#block-edits-to-protected-files
pre_write_cmd = (
    "f=\"$(jq -r \x27.tool_input.file_path // empty\x27 2>/dev/null)\"; "
    "case \"$f\" in "
    "  *.env|*.env.*|*/credentials/*|*/secrets/*|*/.ssh/*|*.pem|*.key|*.p12|*.pfx) "
    "    echo \"BLOCKED by Claude Code Forge: refused to write to protected path: $f\" >&2; "
    "    exit 2;; "
    "esac; exit 0"
)

settings = {
    "permissions": {
        "defaultMode": "default",
        "allow": [
            # File ops — Read/Edit/Write на весь проект (deny ниже сужает чувствительные).
            "Read(**/*)",
            "Edit(**/*)",
            "Write(**/*)",
            # Package manager — узкие команды, не "npm *".
            f"Bash({pkg} install)",
            f"Bash({pkg} ci)",
            f"Bash({pkg} run *)",
            f"Bash({pkg} test*)",
            "Bash(npx --no-install *)",
            "Bash(node *)",
            # Git — только безопасные subcommands (write-команды spell out).
            "Bash(git add *)",
            "Bash(git commit *)",
            "Bash(git checkout -b *)",
            "Bash(git checkout *)",
            "Bash(git branch *)",
            "Bash(git fetch*)",
            "Bash(git pull --ff-only*)",
            "Bash(git push origin *)",
            "Bash(git stash *)",
            "Bash(git merge *)",
            "Bash(git rebase *)",
            "Bash(git restore --staged *)",
            "Bash(git tag*)",
            # Filesystem write — точечные операции, ОПАСНЫЕ (rm, mv) разрешены, но deny ниже блокирует деструктив.
            "Bash(mkdir *)",
            "Bash(cp *)",
            "Bash(mv *)",
            "Bash(touch *)",
            # GitHub CLI — для PR/issue workflow.
            "Bash(gh pr *)",
            "Bash(gh issue *)",
            "Bash(gh repo view*)",
            "Bash(gh api*)",
            # WebFetch — узкий список доменов для docs.
            "WebFetch(domain:docs.anthropic.com)",
            "WebFetch(domain:code.claude.com)",
            "WebFetch(domain:github.com)",
            "WebFetch(domain:developer.mozilla.org)",
            # Built-in subagents (Read-only research).
            "Agent(Explore)",
            "Agent(Plan)",
            "Agent(general-purpose)"
        ],
        "deny": [
            # Секреты (gitignore syntax: bare filename матчит на любой глубине).
            "Read(.env)",
            "Read(.env.*)",
            "Read(**/*.pem)",
            "Read(**/*.key)",
            "Read(**/*.p12)",
            "Read(**/*.pfx)",
            "Read(**/credentials/**)",
            "Read(**/secrets/**)",
            "Read(**/.ssh/**)",
            "Read(**/.aws/credentials)",
            "Read(**/.aws/config)",
            "Edit(.env)",
            "Edit(.env.*)",
            "Write(.env)",
            "Write(.env.*)",
            "Edit(**/credentials/**)",
            "Write(**/credentials/**)",
            "Edit(**/secrets/**)",
            "Write(**/secrets/**)",
            # Безопасность Bash. Сетевые команды — через WebFetch (predictable allowlist).
            "Bash(curl *)",
            "Bash(wget *)",
            "Bash(nc *)",
            "Bash(ncat *)",
            "Bash(sudo *)",
            "Bash(sudo)",
            "Bash(su *)",
            # Деструктив (PreToolUse hook дублирует на runtime — defense in depth).
            "Bash(rm -rf /)",
            "Bash(rm -rf /*)",
            "Bash(rm -rf ~)",
            "Bash(rm -rf ~/*)",
            "Bash(rm -rf $HOME*)",
            "Bash(git push --force*)",
            "Bash(git push -f*)",
            "Bash(git reset --hard*)",
            "Bash(git clean -fd*)",
            "Bash(git clean -f*)",
            "Bash(git checkout .)",
            "Bash(git restore .)",
            # Чувствительные системные пути.
            "Edit(/etc/**)",
            "Edit(/usr/**)",
            "Edit(/var/**)",
            "Write(/etc/**)",
            "Write(/usr/**)",
            "Write(/var/**)",
            # Защита .git/, .vscode/ и т.п. — Claude Code сам protected, но дублируем.
            "Edit(.git/**)",
            "Write(.git/**)",
            "Edit(.husky/**)",
            "Write(.husky/**)"
        ],
        "ask": [
            # Чувствительные операции — требуют явного approval, не блокируются полностью.
            "Bash(git push*)",
            "Bash(gh pr merge*)",
            "Bash(gh release*)",
            "Bash(docker push*)",
            "Bash(kubectl*)",
            f"Bash({pkg} publish*)",
            "Bash(rm -rf *)"
        ]
    },
    "hooks": {
        "PostToolUse": [
            {
                "matcher": "Edit|Write",
                "hooks": [
                    {"type": "command", "command": post_edit_cmd}
                ]
            }
        ],
        "PreToolUse": [
            {
                "matcher": "Bash",
                "hooks": [
                    {"type": "command", "command": pre_bash_cmd}
                ]
            },
            {
                "matcher": "Write|Edit",
                "hooks": [
                    {"type": "command", "command": pre_write_cmd}
                ]
            }
        ]
    },
    "autoMemoryEnabled": True
}

with open(".claude/settings.json", "w", encoding="utf-8") as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write("\n")
'

print_substep "Permissions: суженный allow (без read-only — Claude Code знает встроенно)"
print_substep "Deny: секреты (.env, .pem, .key), деструктив (rm -rf /, git push --force main/master/prod), curl|sh"
print_substep "Ask: git push, gh pr merge, kubectl, docker push — требуют явного approval"
print_substep "PreToolUse Bash: блокировка по regex (CVE-2025-* mitigations, exit 2)"
print_substep "PreToolUse Edit/Write: блокировка записи в .env/secrets/credentials"
print_substep "PostToolUse: auto-format + auto-lint через jq + stdin"

# Создаём шаблон .claude/settings.local.json для личных настроек (в .gitignore)
cat > .claude/settings.local.json << 'LOCAL_SETTINGS_EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "//": "Личные настройки этого проекта. Файл в .gitignore — не коммитить.",
  "//model": "Раскомментируйте для override модели на этом проекте:",
  "//model_example": "\"model\": \"claude-opus-4-7\"",
  "//permissions": "Дополнительные personal allow/deny:",
  "permissions": {
    "allow": [],
    "deny": []
  }
}
LOCAL_SETTINGS_EOF
print_substep ".claude/settings.local.json — шаблон личных настроек (в .gitignore)"

if [ "$JQ_AVAILABLE" -eq 0 ]; then
  print_warning "jq не найден — хуки Claude Code не будут работать. Установите: apt install jq | brew install jq"
fi

# ══════════════════════════════════════════════════════════════════════════════
# .claudeignore
# ══════════════════════════════════════════════════════════════════════════════

print_step "Генерирую .claudeignore..."

cat > .claudeignore << 'EOF'
# Secrets & credentials
.env*
*.pem
*.key
*.p12
*.pfx
credentials/
secrets/

# Dependencies
node_modules/
.venv/
venv/
__pycache__/
*.pyc

# Build artifacts
dist/
build/
.next/
out/
*.min.js
*.min.css
*.map

# Data files (слишком большие для контекста)
*.csv
*.sql
*.db
*.sqlite
*.sqlite3
*.log

# IDE & OS
.idea/
*.swp
*.swo
.DS_Store
Thumbs.db

# Lock files (раскомментируйте, если хотите исключить из контекста.
# По умолчанию оставлены — нужны для отладки проблем с зависимостями).
# package-lock.json
# yarn.lock
# pnpm-lock.yaml
# poetry.lock

# Archives
*.zip
*.tar.gz
*.rar

# Done tasks
_done/
EOF

print_substep ".claudeignore создан"

# ══════════════════════════════════════════════════════════════════════════════
# Skills (актуальный формат Claude Code 2026)
# Source: https://code.claude.com/docs/en/skills
# ══════════════════════════════════════════════════════════════════════════════
#
# Skills — рекомендованный формат вместо устаревших .claude/commands/*.md.
# Каждый skill — отдельная директория .claude/skills/<name>/SKILL.md с YAML-frontmatter.
# Преимущества над commands: allowed-tools (granular permissions), disable-model-invocation
# (для side-effect команд), context: fork (запуск в subagent), dynamic context через !`cmd`.
#
# ВАЖНО: Claude Code имеет built-in /review, /security-review, /init, /run, /verify.
# Наши skill-имена выбраны чтобы не конфликтовать (например /code-review вместо /review).

print_step "Создаю Skills (.claude/skills/)..."

# /freshstart — начало новой сессии (автозагрузка контекста)
mkdir -p .claude/skills/freshstart
cat > .claude/skills/freshstart/SKILL.md << 'EOF'
---
description: Старт рабочей сессии. Прочитай CLAUDE.md, memory-bank, TASKS, последний handoff и доложи статус. Используй когда пользователь говорит "начнём", "продолжим работу", "восстанови контекст" или просто запускает новую сессию.
when_to_use: При старте новой сессии, после /clear, после долгого перерыва в работе.
allowed-tools: Read Bash(git log*) Bash(git status*) Bash(ls *)
---

## Текущее состояние git

!`git log --oneline -10 2>/dev/null || echo "(не git-репозиторий)"`
!`git status --short 2>/dev/null || echo "(не git-репозиторий)"`

## Последний handoff

!`ls -t _todo/handoff-*.md 2>/dev/null | head -1 | xargs -r cat | head -100`

## Задача

1. Прочитай CLAUDE.md, PLANNING.md, TASKS.md
2. Прочитай memory-bank/{projectbrief,activeContext,progress}.md
3. На основе git-состояния и handoff выше — кратко (5-7 строк) доложи:
   - Текущий статус проекта (1-2 предложения)
   - Последние выполненные задачи (2-3 пункта)
   - Рекомендуемая следующая задача с обоснованием из TASKS.md
   - Потенциальные блокеры или вопросы
EOF
print_substep "/freshstart — восстановление контекста с git/handoff контекстом"

# /plan — планирование задачи в Plan Mode
mkdir -p .claude/skills/plan
cat > .claude/skills/plan/SKILL.md << 'EOF'
---
description: Спланируй задачу в Plan Mode — прочитай контекст, оцени impact, предложи подход с тестами и рисками. Используй для задач >30 минут, многофайловых изменений, незнакомых частей кодобазы. Anthropic называет это "the single biggest quality lever".
when_to_use: Перед любой нетривиальной задачей, перед началом реализации сложной фичи.
argument-hint: "<описание задачи>"
allowed-tools: Read Grep Glob Bash(git log*) Bash(git diff*)
---

Спланируй задачу: $ARGUMENTS

## Контекст

Прочитай в указанном порядке:
1. `CLAUDE.md`, `PLANNING.md`, `TASKS.md`
2. `memory-bank/activeContext.md` (если есть)
3. Соответствующие ADR из `adr/` (если есть)
4. Прямо затронутые файлы кода

## План (выдай в этом формате)

### Затронутые модули и файлы
- путь → природа изменения

### Подход (с обоснованием)
- Опиши решение в 3-7 пунктах
- Если есть альтернативы — упомяни и почему выбран этот вариант

### Тесты (FIRST — по TDD)
- Список тест-кейсов, которые нужно написать ПЕРЕД кодом
- Happy path + минимум 2 edge case + 1 error case на каждую публичную функцию

### Риски и точки внимания
- Что может сломаться в смежных частях системы
- Migration / backward compatibility concerns

### Размер задачи
S (<1ч) | M (1-4ч) | L (4-8ч) | XL (>8ч — РАЗБЕЙ на подзадачи S-M)

### ADR-impact
- Соответствует существующим ADR? Нужен новый? (если да — спроси подтверждения)

ВАЖНО: НЕ вноси изменений в код. Только план. Реализация — отдельным запросом или через /implement.
EOF
print_substep "/plan — Plan Mode с TDD-первой декомпозицией"

# /implement — TDD реализация
mkdir -p .claude/skills/implement
cat > .claude/skills/implement/SKILL.md << 'EOF'
---
description: Реализуй задачу по строгому TDD-циклу RED → GREEN → REFACTOR. Сначала падающий тест, потом минимальный код, потом рефактор. Используй когда план готов и нужно превратить его в код.
argument-hint: "<задача>"
when_to_use: После /plan, когда у тебя есть структурированный план реализации.
---

Задача: $ARGUMENTS

## Процесс

Для каждого шага плана выполни цикл TDD:

### RED
1. Напиши ОДИН падающий тест на конкретное поведение
2. Запусти его — убедись что падает с осмысленной ошибкой (не syntax error)
3. Если тест падает не по той причине — почини сам тест

### GREEN
1. Напиши МИНИМАЛЬНЫЙ код для прохождения теста
2. Никаких "ещё пригодится" — только то, что нужно для текущего теста
3. Запусти — убедись что зелёный

### REFACTOR
1. Улучши код, сохраняя зелёный тест-сьют
2. Извлеки дубликат, переименуй непонятное, разбей длинное
3. Запусти тесты после каждого изменения

## Запреты (нарушение = провал TDD)

- НЕ менять тест чтобы он прошёл с текущим кодом
- НЕ пропускать RED-фазу ("я уверен что он сломан")
- НЕ реализовывать функционал без теста
- НЕ писать "за один раз" 5 фич без зелёного промежутка

## По завершении

1. Запусти полный тест-сьют — должен быть зелёным
2. Запусти линтер — должен быть зелёным
3. Запусти type-checker (если есть) — должен быть зелёным
4. Обнови `TASKS.md` (отметь [x])
5. Обнови `memory-bank/activeContext.md` и `progress.md`
6. Доложи: что сделано, какие тесты добавлены, есть ли регрессии
EOF
print_substep "/implement — TDD RED → GREEN → REFACTOR (verification = #1 leverage)"

# /code-review — самопроверка изменений (не /review — конфликт с built-in)
mkdir -p .claude/skills/code-review
cat > .claude/skills/code-review/SKILL.md << 'EOF'
---
description: Self-review текущих изменений с классификацией BLOCKER/WARNING/SUGGESTION. Особое внимание к типичным проблемам AI-кода — над-инжиниринг, фантомные зависимости, потерянная защитная логика. Используй перед коммитом или открытием PR.
argument-hint: "[scope: staged|branch|<file-path>]"
when_to_use: Перед коммитом, перед открытием PR, перед мержем.
allowed-tools: Read Grep Glob Bash(git diff*) Bash(git log*) Bash(git status*)
---

## Изменения для ревью

!`git diff --stat HEAD 2>/dev/null || git status --short`

!`git diff HEAD 2>/dev/null | head -500`

## Задача

Скоуп: $ARGUMENTS (по умолчанию — текущая ветка vs main)

Проведи строгое self-review. Для каждого изменённого файла проверь:

### Корректность
- Бизнес-логика соответствует требованиям из PRD/PLANNING
- Edge cases обработаны (null, empty, max value, race condition)
- Error handling уместен и информативен

### Безопасность
- Нет хардкода секретов, API ключей, токенов
- Все пользовательские входы валидируются
- SQL — только параметризованные запросы
- HTML — экранирование (нет dangerouslySetInnerHTML без причины)
- Зависимости — нет ли новых suspicious пакетов (slopsquatting risk)

### AI-code специфика (важно!)
- Не введено ли ненужных абстракций (Factory/Repository/Strategy там, где функция бы решила)
- Не удалена ли защитная логика (null checks, rate limits, idempotency)
- Не появилось ли фантомных зависимостей (несуществующие npm/pip пакеты)
- Не введено ли дублирования вместо переиспользования

### Качество
- N+1 запросы, утечки памяти
- Тесты на каждый публичный метод
- Соответствие архитектурным паттернам из CLAUDE.md и ADR

## Формат отчёта

```
🔴 BLOCKER (N) — нельзя мержить
  - file:line — описание — фикс
🟡 WARNING (M) — желательно исправить до мержа
  - file:line — описание — фикс
🔵 SUGGESTION (K) — улучшение на потом
  - file:line — описание
```

Если 0 BLOCKER и 0 WARNING — явно скажи "PR готов к мержу".
EOF
print_substep "/code-review — self-review с AI-specific checklist"

# /handoff — передача контекста между сессиями
mkdir -p .claude/skills/handoff
cat > .claude/skills/handoff/SKILL.md << 'EOF'
---
description: Создай handoff-документ в _todo/handoff-YYYY-MM-DD.md для передачи контекста следующей сессии и обнови memory-bank. Используй в конце рабочей сессии или перед /clear на длинной задаче.
disable-model-invocation: true
allowed-tools: Read Write Edit Bash(date *) Bash(git log*) Bash(git diff*) Bash(git status*)
---

## Контекст сессии

!`date +%Y-%m-%d`
!`git log --oneline -20 2>/dev/null`
!`git diff --stat 2>/dev/null`

## Задача

Создай `_todo/handoff-YYYY-MM-DD.md` (подставь сегодняшнюю дату из контекста выше). Структура:

```markdown
# Session Handoff — YYYY-MM-DD

## Цель сессии
1-2 предложения о том, что планировалось

## Что сделано
- Конкретный список с файлами и краткой сутью
- Со ссылками file:line на ключевые места

## Ключевые решения
- Решения с обоснованием — кандидаты для ADR
- Если что-то стоит закрепить — пометь "→ создать ADR"

## Тупики и отвергнутые подходы
- Что попробовали и почему не сработало (важно — экономит время следующей сессии)

## Текущий статус
- Работает: ...
- Сломано: ...
- В процессе: ... (файлы и куда смотреть)

## Следующие шаги (приоритет)
1. ...
2. ...
3. ...

## Активные файлы
Полные пути файлов, открытых/изменённых в сессии

## Контекст для отладки
Ошибки которые видели, как их обходили, неочевидные зависимости
```

## Также обнови

1. `memory-bank/activeContext.md` — поставь текущий focus = первая задача из "Следующие шаги"
2. `memory-bank/progress.md` — отметь завершённые пункты в "Завершено", обнови "В процессе"
3. `TASKS.md` — `[ ]` → `[x]` для завершённого, `[ ]` → `[~]` для in-progress

В конце доложи: "Handoff сохранён в `_todo/handoff-YYYY-MM-DD.md`. Безопасно завершать сессию."
EOF
print_substep "/handoff — передача контекста (disable-model-invocation: side-effects)"

# /compact-save — подготовка к компакции
mkdir -p .claude/skills/compact-save
cat > .claude/skills/compact-save/SKILL.md << 'EOF'
---
description: Подготовь контекст к /compact — сохрани в файлы memory-bank всё, что критично сохранить, чтобы не потерять при сжатии. Используй при заполнении контекста 60-80% (не жди auto-compact на 83%).
disable-model-invocation: true
allowed-tools: Read Write Edit
---

## Задача

Перед `/compact` сохрани в персистентные файлы всё, что должно пережить сжатие:

1. **Обнови `memory-bank/activeContext.md`**:
   - Текущий focus (одно предложение)
   - Что в работе прямо сейчас (3-5 пунктов)
   - Активные файлы и их роли
   - Открытые вопросы

2. **Обнови `memory-bank/progress.md`**:
   - Завершённые задачи (с датой)
   - Известные баги/issues (если обнаружены в этой сессии)

3. **Если есть промежуточный debug-контекст — запиши в `_todo/session-notes.md`**:
   - Отвергнутые подходы и причины
   - Неочевидные зависимости между файлами
   - Баги, которые видели но не исправили
   - Промежуточные результаты исследования

4. В конце сообщи пользователю:
   ```
   Контекст сохранён. Безопасно вызвать:
   /compact "сохрани X, Y, Z из текущей задачи"
   ```

ВАЖНО: чем раньше /compact (60% а не 80%), тем меньше теряется. Auto-compact на 83% уже слишком поздно — модель уже деградирует с 60%+.
EOF
print_substep "/compact-save — preserve context до /compact (60%, не 80%)"

# /adr — Architecture Decision Record
if [ "$METHOD_LEVEL" -ge 2 ]; then
mkdir -p .claude/skills/adr
cat > .claude/skills/adr/SKILL.md << 'EOF'
---
description: Создай новый Architecture Decision Record в adr/NNN-slug.md. Используй когда принимается нетривиальное архитектурное решение, которое стоит зафиксировать для будущих сессий.
disable-model-invocation: true
argument-hint: "<тема решения>"
allowed-tools: Read Write Bash(ls *)
---

## Существующие ADR

!`ls -1 adr/*.md 2>/dev/null | grep -v _template`

## Задача

Создай ADR на тему: $ARGUMENTS

1. Определи следующий свободный номер (формат `NNN-slug.md`, 3 цифры с ведущими нулями, начиная с 001)
2. Создай файл `adr/NNN-короткий-slug.md` по шаблону `adr/_template.md`
3. Заполни секции:
   - **Status**: Proposed (по умолчанию для нового)
   - **Context**: какая проблема, какие силы давят на решение
   - **Decision**: что именно решили (одно предложение в активном залоге)
   - **Alternatives Considered**: минимум 2 альтернативы с плюсами/минусами
   - **Consequences**: Positive / Negative / Risks
4. Добавь ссылку на новый ADR в CLAUDE.md в секцию Architecture Decision Records
5. Обнови `memory-bank/systemPatterns.md` (если решение касается паттернов)
6. Закоммить файлом отдельно: `chore(adr): NNN — <slug>`
EOF
print_substep "/adr — создание Architecture Decision Record"
fi

# /security-audit — запускается в forked subagent (изолированный контекст)
mkdir -p .claude/skills/security-audit
cat > .claude/skills/security-audit/SKILL.md << 'EOF'
---
description: Аудит безопасности — секреты, инъекции, XSS, supply chain (slopsquatting), CORS, auth. Запускается в forked Explore-агенте, не засоряет основной контекст результатами grep по всему репо.
argument-hint: "[scope: all|src/|<path>]"
context: fork
agent: Explore
allowed-tools: Read Grep Glob Bash(npm audit*) Bash(pip-audit*) Bash(git log*)
---

## Задача

Проведи security-аудит. Скоуп: $ARGUMENTS (по умолчанию — весь проект)

### 1. Утечка секретов
- Grep по `password|secret|api[_-]key|token|private[_-]key|bearer` в `src/`, `tests/`, `config/`
- Учитывай типичные паттерны: `sk_`, `AKIA`, `ghp_`, `xox[bps]-`, `-----BEGIN`
- Проверь git history: `git log --all -p -- ".env*" "**/credentials/*" "**/secrets/*"`

### 2. Injection
- **SQL**: raw SQL без параметризации, конкатенация в queries
- **Command**: `exec(`, `system(`, `subprocess.run(...shell=True...)` с пользовательским вводом
- **Path traversal**: file paths из user input без normalize/проверки

### 3. XSS / Frontend
- `dangerouslySetInnerHTML` / `v-html` / `innerHTML` с user data
- Непроэскейпленный вывод в templates
- `eval`, `new Function`, `setTimeout(string, ...)`

### 4. Supply chain (актуально для 2026)
- `npm audit` / `pip-audit` / `cargo audit`
- Suspicious новые зависимости: проверь deps.dev / ecosys.dev
- Slopsquatting: пакеты с подозрительно "почти-как-известные" имена
- Малоизвестные maintainers на critical paths

### 5. Auth / Authorization
- Токены без expiry
- Отсутствие rate limiting на login/password reset/2FA
- IDOR — endpoints без проверки ownership
- Слабая crypto: MD5/SHA1 для паролей, AES-ECB

### 6. CORS / Headers
- `Access-Control-Allow-Origin: *` с credentials
- Отсутствие CSP, X-Frame-Options, X-Content-Type-Options

### 7. Permissions / Filesystem
- Файлы с правами 777
- Исполняемые скрипты в загрузочных директориях

## Формат отчёта

```
CRITICAL (N) — устранить НЕМЕДЛЕННО (CVE-уровень)
  - <file:line> — <issue> — <fix>
HIGH (M) — устранить до релиза
  - ...
MEDIUM (K) — устранить в спринте
  - ...
LOW (P) — улучшения
  - ...
```

Если ничего критичного — явно скажи "BASELINE: критичных уязвимостей не обнаружено". Не выдумывай.
EOF
print_substep "/security-audit — fork-subagent аудит (изолированный контекст, не засоряет main)"

# /commit — атомарный коммит по conventional commits (опасный — disable-model-invocation)
mkdir -p .claude/skills/commit
cat > .claude/skills/commit/SKILL.md << 'EOF'
---
description: Создай атомарный git-коммит по conventional commits. Сначала покажет diff, спросит подтверждения, затем commit. Используй когда готов зафиксировать изменения.
disable-model-invocation: true
allowed-tools: Bash(git status*) Bash(git diff*) Bash(git add *) Bash(git commit *)
---

## Текущее состояние

!`git status --short`
!`git diff --staged --stat`
!`git diff --staged | head -300`

## Задача

1. Если ничего не staged — покажи `git diff --stat` и спроси что добавить (НЕ делай `git add .` сам — это анти-паттерн)
2. Проанализируй staged diff и определи тип коммита:
   - `feat:` — новая функциональность
   - `fix:` — исправление бага
   - `refactor:` — улучшение без изменения поведения
   - `docs:` — только документация
   - `test:` — только тесты
   - `chore:` — служебное (deps, config)
   - `perf:` — улучшение производительности
   - `style:` — форматирование
3. Сформулируй commit message (subject ≤72 символа, императив "add" не "added"):
   ```
   <type>(<scope>): <краткое описание>

   <тело — почему, не что>

   <footer — refs/closes #issue>
   ```
4. Покажи планируемое сообщение пользователю и спроси подтверждения
5. После подтверждения — `git commit -m "..."` (через heredoc для многострочных)

ВАЖНО:
- Один коммит = одно логическое изменение. Если staged diff делает 2+ вещи — разбей.
- НЕ добавляй `Co-Authored-By: Claude` или другие AI-tagging если пользователь не попросил
- НЕ делай `git add .` или `git add -A` — это часто захватывает мусор
EOF
print_substep "/commit — conventional commits, требует подтверждения diff"

# ══════════════════════════════════════════════════════════════════════════════
# Subagents (.claude/agents/) — специализированные AI с собственным контекстом
# Source: https://code.claude.com/docs/en/sub-agents
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю специализированных subagents..."

mkdir -p .claude/agents

# code-reviewer — изолированный контекст для review-задач
cat > .claude/agents/code-reviewer.md << 'EOF'
---
name: code-reviewer
description: Senior software engineer who reviews code changes for correctness, security, performance, and adherence to project conventions. Use when reviewing a diff, PR, or specific files. Catches AI-code antipatterns (over-abstraction, phantom dependencies, dropped defensive logic).
tools: Read, Grep, Glob, Bash
model: opus
---

You are a senior engineer doing rigorous code review. You have no context about prior conversation — review only what you're given.

## Process

1. Identify the scope: `git diff main`, specific files, or whatever was passed.
2. For each changed file, evaluate:

### Correctness
- Does the logic match what the PR description / spec claims?
- Are edge cases handled (null, empty, max value, race conditions)?
- Is error handling appropriate and informative?

### Security
- No hardcoded secrets, API keys, tokens
- All user inputs validated; no concatenation in SQL/shell
- HTML output escaped; no `dangerouslySetInnerHTML` without justification
- New dependencies: any look like slopsquatting candidates? Check deps.dev/ecosys.dev mental model.

### AI-code antipatterns (critical for 2026)
- **Over-abstraction**: unnecessary Factory/Repository/Strategy where a function would do
- **Phantom packages**: dependencies that don't exist or are typosquatted
- **Dropped defensive logic**: null checks, rate limits, idempotency removed silently during refactor
- **Sprawl**: 5 new files where 1 would suffice; premature interfaces

### Performance
- N+1 queries, leaks (closures retaining large objects, unclosed resources)
- Unnecessary re-renders / re-computations

### Tests & conventions
- Every public method has a test
- Style/architecture matches CLAUDE.md and existing ADRs

## Output format

```
🔴 BLOCKER (count) — block merge
  - <file:line> — <issue> — <suggested fix>
🟡 WARNING (count) — fix before merge
  - <file:line> — <issue> — <suggested fix>
🔵 SUGGESTION (count) — future improvement
  - <file:line> — <issue>

VERDICT: APPROVE | REQUEST CHANGES | NEEDS DISCUSSION
```

If clean — explicitly state `VERDICT: APPROVE — no blockers, no warnings`. Do not invent issues.
EOF
print_substep "code-reviewer subagent — opus, изолированный контекст для PR-review"

# security-reviewer — узкоспециализированный аудит
cat > .claude/agents/security-reviewer.md << 'EOF'
---
name: security-reviewer
description: Application security engineer who reviews code for vulnerabilities (OWASP Top 10, injection, secrets exposure, supply chain). Use when you need a security-focused review separate from general code review.
tools: Read, Grep, Glob, Bash
model: opus
---

You are an application security engineer. Review for vulnerabilities only.

## Checklist (in order of priority)

1. **Secrets exposure**: hardcoded keys/tokens/passwords, secrets in logs, secrets in git history
2. **Injection**: SQL (raw queries), command (shell=True), path traversal, template injection
3. **Authentication/Authorization**: missing checks, IDOR, weak crypto (MD5/SHA1 for passwords), tokens without expiry, no rate limiting on auth endpoints
4. **XSS / CSRF**: unescaped output, dangerouslySetInnerHTML, missing CSRF tokens on state-changing endpoints
5. **SSRF**: server-side fetch with user-controlled URL, no allowlist
6. **Insecure deserialization**: `pickle.loads`, `yaml.load`, `eval`, `Function()`
7. **Supply chain**: new dependencies — check for slopsquatting/typosquatting. Suspicious patterns: unknown maintainer, recent publish date, similar-to-popular name
8. **Crypto**: ECB mode, custom crypto, hardcoded IVs, predictable randomness for security purposes
9. **CORS / Headers**: `Access-Control-Allow-Origin: *` with credentials, missing CSP, X-Frame-Options
10. **Sensitive data**: PII in logs, secrets in error messages, debug info leakage in production

## Output

For each finding: severity (CRITICAL/HIGH/MEDIUM/LOW), file:line, exploit scenario, fix.
If nothing — state "Baseline: no security vulnerabilities found in reviewed scope".
EOF
print_substep "security-reviewer subagent — узкая фокусировка на OWASP + supply chain"

# test-writer — генерация тестов
cat > .claude/agents/test-writer.md << 'EOF'
---
name: test-writer
description: Specialized in writing high-quality tests (TDD-first). Use when you need to add tests for existing code or generate test scaffolding before implementation. Follows project's test conventions.
tools: Read, Edit, Write, Grep, Glob, Bash
model: sonnet
---

You write tests that catch real bugs, not tests that pad coverage.

## Principles

- One behavior per test. If it needs "and", split.
- Test name: `should <expected behavior> when <condition>` (or project-equivalent)
- For each public function: happy path + minimum 2 edge cases + 1 error case
- Mocks ONLY for external deps (API, DB, FS), NEVER for internal modules — internal mocks freeze design
- Property-based tests for pure functions with complex domain (use hypothesis/fast-check if available)
- Snapshot tests sparingly — only for stable visual/serialized output
- AVOID: testing implementation details (private methods, internal state), test ordering dependencies

## Process

1. Read the code being tested to understand contracts (NOT implementation)
2. Check existing tests for project style/framework
3. Read CLAUDE.md and `.claude/rules/testing.md` if present
4. Write tests following project conventions
5. Run them — verify they fail/pass as expected
6. Report: what's covered, what's NOT covered and why (e.g. "integration tests skipped — require DB fixture")
EOF
print_substep "test-writer subagent — sonnet, TDD-first generation"

# ══════════════════════════════════════════════════════════════════════════════
# Path-scoped rules (.claude/rules/) — авто-загружаемые при работе с matching файлами
# Source: https://code.claude.com/docs/en/memory#path-specific-rules
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю модульные правила .claude/rules/ (path-scoped)..."

# testing.md — авто-загружается только при работе с тестами
cat > .claude/rules/testing.md << 'EOF'
---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/tests/**"
  - "**/__tests__/**"
  - "**/test_*.py"
  - "**/*_test.go"
---

# Testing Rules (auto-loaded when editing tests)

## Strict TDD

- НИКОГДА не модифицируй тест, чтобы он проходил с текущей реализацией. Если тест "неудобен" — это сигнал что код плохой, а не тест.
- RED → GREEN → REFACTOR — без пропусков. Запусти тест и убедись что он падает осмысленно, прежде чем писать код.
- Каждый тест проверяет ОДНО поведение. Если в названии "and" — разбей.

## Naming & structure

- Имя теста описывает поведение: `should <expected> when <condition>`
- AAA: Arrange / Act / Assert — разделено пустыми строками или комментариями
- Group: используй `describe`/`context`/класс на единицу абстракции

## Coverage requirements

- Каждая публичная функция: happy path + минимум 2 edge case + 1 error case
- Async — обязательно тест на timeout/cancel
- Race conditions — отдельные тесты с `Promise.race` / parallel

## Mocking

- Моки ТОЛЬКО для внешних зависимостей (HTTP, DB, FS, time)
- НЕ моки для внутренних модулей — это freezes design и мешает рефакторингу
- Предпочти fake/stub (детерминистичная мини-имплементация) поверх mock (assertion на calls)

## Anti-patterns (не делать)

- Snapshot-тесты для всего подряд — только для стабильного serialized output
- Тесты приватных методов через reflection
- Зависимость тестов друг от друга (порядок выполнения, общее состояние)
- `setTimeout(..., 100)` для async — используй proper async/await или fake timers
EOF
print_substep "testing.md — path-scoped (auto-loaded для test-файлов)"

# security.md — глобальное (без paths — применяется всегда)
cat > .claude/rules/security.md << 'EOF'
# Security Rules (всегда применяются)

## Секреты

- НИКОГДА не хардкодить секреты, пароли, API ключи, токены
- Все секреты — через переменные окружения или secret manager (Vault, AWS Secrets, GCP Secret Manager)
- НИКОГДА не логировать секреты, пароли, токены, PII
- НИКОГДА не отправлять секреты во внешние сервисы (telemetry, error tracking) — фильтровать!

## Inputs

- ВСЕГДА валидируй пользовательский ввод на границе системы (zod, pydantic, validator)
- SQL — ТОЛЬКО параметризованные запросы (никакой конкатенации)
- Shell — НИКОГДА `shell=True` с пользовательским вводом; используй args-list
- File paths — нормализуй и проверяй на path traversal (`../`)

## Output

- HTML — экранируй пользовательские данные. `dangerouslySetInnerHTML` / `v-html` только с sanitized HTML (DOMPurify)
- HTTP responses — устанавливай Content-Type, Content-Security-Policy, X-Frame-Options

## Auth

- Токены с expiry (access ≤15 мин, refresh ≤30 дней)
- Rate limiting на login, password reset, 2FA, signup
- Пароли: argon2id или bcrypt (cost ≥12), НИКОГДА MD5/SHA1
- Session fixation: ротация session ID после login

## Supply chain (актуально для 2026)

- Новые зависимости — проверь репутацию: deps.dev, ecosys.dev, npm stats
- Slopsquatting: 19.7% LLM-предложенных пакетов галлюцинированы. ВСЕГДА проверяй существование пакета перед install
- Lockfiles обязательны; CI должен fail если lockfile out of sync
- `npm install --ignore-scripts` для AI-driven installs
EOF
print_substep "security.md — глобальное правило (загружается всегда)"

# git.md — глобальное
cat > .claude/rules/git.md << 'EOF'
# Git Rules (всегда применяются)

## Commits

- Conventional commits: `<type>(<scope>): <subject>` (типы: feat, fix, refactor, docs, test, chore, perf, style)
- Один коммит = одно логическое изменение. Если в коммите "and" — разбей.
- Subject: императив, ≤72 символа, без точки в конце
- Body (опц.): почему, не что. Что — видно в diff.

## Branching

- `feature/<descriptor>`, `bugfix/<descriptor>`, `hotfix/<descriptor>`, `chore/<descriptor>`
- НЕ работать прямо в main/master
- НЕ форс-пушить в shared ветки (main, master, develop, release/*)

## Перед коммитом

- Запустить тесты — должны быть зелёными
- Запустить линтер — без ошибок
- Self-review через `/code-review`

## Что НЕ коммитить

- `.env*`, `*.pem`, `*.key`, `credentials/`, `secrets/`
- Сгенерированные файлы (`dist/`, `build/`, `.next/`, `__pycache__/`)
- `node_modules/`, `.venv/`
- IDE-локальные файлы (`.idea/settings.xml`, `.vscode/launch.json` без шаблона)
- Большие бинарники без LFS
EOF
print_substep "git.md — глобальное правило (загружается всегда)"

# code-quality.md — anti-overengineering правила (#1 antipattern AI-кода)
cat > .claude/rules/code-quality.md << 'EOF'
# Code Quality Rules (всегда применяются)

Эти правила противодействуют доказанным антипаттернам AI-генерации
(METR study 2025, Shopify playbook, GitClear data).

## YAGNI (You Aren't Gonna Need It)

- НЕ добавляй абстракции "на будущее". Один конкретный use case — одна функция.
- НЕ создавай Factory/Builder/Strategy если есть один тип. Это можно добавить когда появится второй.
- НЕ выноси в утилиту функцию которая используется один раз.
- Три похожих места — не повод для абстракции. Пять — повод подумать. Семь — повод выносить.

## Prefer functions over classes

- Если у класса один метод (кроме `__init__`/конструктора) — это функция.
- Если класс — это просто bag of state без поведения — используй dataclass/record/struct.
- ООП оправдано когда есть полиморфизм И состояние И инвариант. Иначе функция.

## Locality of behavior

- Лучше 30 строк подряд чем 5 файлов по 6 строк
- Не разбивай функцию на под-функции "для читаемости" если они не переиспользуются — это просто прыжки glob по файлу

## Defensive code — оставлять там, где было

- При рефакторинге: НЕ удаляй null-checks, validation, idempotency guards "потому что не используются"
- Они были добавлены для причины. Спроси прежде чем удалять.

## Тонкие зависимости

- НЕ добавляй npm/pip пакет ради одной функции. `_.isEmpty()` — это `!arr.length`.
- Каждая новая зависимость = транзитивная supply chain ответственность
- Проверь deps.dev/ecosys.dev перед добавлением

## Comments

- НЕ пиши "что делает код" — это видно из кода. Пиши ПОЧЕМУ (если неочевидно).
- НЕ дублируй сигнатуру функции в docstring без новой информации
- TODO без owner и даты — мусор. `# TODO(name, 2026-Q3): why`
EOF
print_substep "code-quality.md — anti-overengineering (YAGNI, prefer functions, anti-AI-sprawl)"

# ══════════════════════════════════════════════════════════════════════════════
# Memory Bank (Standard+)
# ══════════════════════════════════════════════════════════════════════════════

if [ "$METHOD_LEVEL" -ge 2 ]; then
  print_step "Инициализирую Memory Bank..."

  cat > memory-bank/projectbrief.md << EOF
# Project Brief: ${PROJECT_NAME}

## Описание
${PROJECT_DESC}

## Ключевые цели
- TODO: Заполнить при первой сессии планирования

## Scope
### В скоупе
- TODO

### Вне скоупа
- TODO

## Целевая аудитория
- TODO

## Метрики успеха
- TODO
EOF
  print_substep "projectbrief.md"

  cat > memory-bank/productContext.md << 'EOF'
# Product Context

## Зачем этот продукт
TODO: Заполнить при планировании

## Пользовательские сценарии
TODO: Основные user flows

## UX-принципы
TODO: Ключевые принципы интерфейса
EOF
  print_substep "productContext.md"

  cat > memory-bank/systemPatterns.md << 'EOF'
# System Patterns

## Архитектура
TODO: Заполняется после первой сессии архитектуры

## Ключевые паттерны
TODO: Используемые паттерны проектирования

## Структура данных
TODO: Основные модели и их связи

## Интеграции
TODO: Внешние сервисы и API
EOF
  print_substep "systemPatterns.md"

  cat > memory-bank/techContext.md << EOF
# Tech Context

## Stack
${TECH_STACK}

## Testing
${TEST_FRAMEWORK}

## Build Commands
- Dev: \`${DEV_CMD}\`
- Build: \`${BUILD_CMD}\`
- Test: \`${TEST_CMD}\`
- Lint: \`${LINT_CMD}\`

## Dev Environment
- TODO: Версии, системные зависимости

## Известные ограничения
- TODO: Заполняется итеративно
EOF
  print_substep "techContext.md"

  cat > memory-bank/activeContext.md << 'EOF'
# Active Context

## Текущий фокус
Проект только инициализирован. Следующий шаг — сессия планирования.

## Недавние изменения
- [дата] — Bootstrap проекта по методологии Claude Code

## Открытые вопросы
- TODO

## Текущие блокеры
- Нет
EOF
  print_substep "activeContext.md"

  cat > memory-bank/progress.md << 'EOF'
# Progress

## Завершено
- [x] Bootstrap проекта

## В процессе
- [ ] Сессия планирования (PRD + архитектура)

## Не начато
- [ ] TODO: Заполнить из TASKS.md

## Known Issues
- Нет
EOF
  print_substep "progress.md"
fi

# ══════════════════════════════════════════════════════════════════════════════
# Файлы планирования
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю файлы планирования..."

cat > PRD.md << EOF
# Product Requirements Document: ${PROJECT_NAME}

## 1. Overview
${PROJECT_DESC}

## 2. Problem Statement
TODO: Какую проблему решает продукт

## 3. Goals & Success Metrics
TODO: Измеримые цели

## 4. User Personas
TODO: Описание целевых пользователей

## 5. Functional Requirements
### 5.1 Core Features (MVP)
TODO: Список фич с приоритетами (P0/P1/P2)

### 5.2 Future Features
TODO: Фичи после MVP

## 6. Non-Functional Requirements
- Производительность: TODO
- Безопасность: TODO
- Масштабируемость: TODO
- Доступность: TODO

## 7. Constraints
TODO: Технические, бизнесовые, временные ограничения

## 8. Out of Scope
TODO: Что явно НЕ входит в проект
EOF
print_substep "PRD.md"

cat > PLANNING.md << EOF
# Planning: ${PROJECT_NAME}

## Architecture
TODO: Заполнить при первой архитектурной сессии

## Tech Stack Rationale
- ${TECH_STACK}
- Обоснование: TODO

## Project Structure
\`\`\`
src/
├── TODO: Определить при планировании
\`\`\`

## API Design
TODO: Ключевые эндпоинты / интерфейсы

## Data Model
TODO: Основные сущности и связи

## Deployment Strategy
TODO: Где и как деплоить

## Development Process
1. Задачи берутся из TASKS.md с учётом зависимостей
2. Каждая задача начинается с Plan Mode
3. Реализация строго по TDD: RED → GREEN → REFACTOR
4. Code review через /review
5. Handoff через /handoff в конце сессии
EOF
print_substep "PLANNING.md"

cat > TASKS.md << 'EOF'
# Tasks

## Milestone 0: Foundation
- [ ] TASK-001: Сессия планирования — заполнить PRD.md, PLANNING.md, архитектуру
- [ ] TASK-002: Настроить dev-окружение (зависимости, конфиги, CI)
- [ ] TASK-003: Создать базовую структуру проекта (каркас без логики)
- [ ] TASK-004: Настроить тестовую инфраструктуру (первый проходящий тест)

## Milestone 1: MVP Core
- [ ] TASK-005: TODO — первая фича (зависит от TASK-003, TASK-004)
- [ ] TASK-006: TODO — вторая фича

## Dependencies
- TASK-003 → TASK-005, TASK-006
- TASK-004 → TASK-005, TASK-006

## Legend
- [ ] TODO  |  [~] In Progress  |  [x] Done  |  [!] Blocked
EOF
print_substep "TASKS.md"

# ══════════════════════════════════════════════════════════════════════════════
# Документация
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю шаблоны документации..."

cat > docs/ARCHITECTURE.md << 'EOF'
# Architecture Overview

TODO: Заполняется после первой архитектурной сессии.

## System Diagram
```
TODO: ASCII-диаграмма или ссылка на Mermaid
```

## Components
TODO: Описание ключевых компонентов

## Data Flow
TODO: Как данные проходят через систему

## External Dependencies
TODO: Внешние сервисы, API, базы данных

## Security Architecture
TODO: Аутентификация, авторизация, шифрование
EOF
print_substep "docs/ARCHITECTURE.md"

if [ "$METHOD_LEVEL" -ge 2 ]; then
  cat > adr/_template.md << 'EOF'
# ADR-NNN: [Заголовок решения в активном залоге]

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-XXX

Date: YYYY-MM-DD
Authors: @name

## Context
Какая проблема, ограничение или необходимость привела к этому решению?
Какие силы давят на это решение (production constraints, legacy, team skills,
deadlines, compliance)?

## Decision
Что именно решили (одно предложение в активном залоге).

## Alternatives Considered

### Вариант A: [Название]
- Плюсы: ...
- Минусы: ...
- Почему не выбран: ...

### Вариант B: [Название]
- Плюсы: ...
- Минусы: ...
- Почему не выбран: ...

## Consequences

### Positive
- ...

### Negative
- ...

### Risks
- ...

## References
- Ссылки на обсуждение в issue/PR/доках
EOF
  print_substep "adr/_template.md"

  # ADR-0001: устанавливаем правила AI-assisted разработки на старте проекта
  cat > adr/0001-ai-assisted-development.md << 'EOF'
# ADR-0001: AI-Assisted Development Standards

## Status
Accepted

Date: YYYY-MM-DD (обнови при первой ревизии)
Authors: bootstrap (claude-code-forge)

## Context

Команда использует Claude Code (или другой агентный AI-ассистент) как
полноценную часть процесса разработки. Это требует явных правил, потому
что AI-инструменты:

- Стабильно ускоряют greenfield и boilerplate (+20-30% по Shopify playbook 2025)
- Стабильно замедляют опытных разработчиков на знакомой кодовой базе
  (-19% по METR RCT 2025-07)
- Генерируют код с 1.7× более высокой плотностью багов чем человеческий
  (Shiplight 2025)
- Создают новые supply-chain риски: 19.7% LLM-предложенных пакетов
  галлюцинированы (slopsquatting)
- Уязвимы к prompt injection через issues, PR-описания, MCP-серверы
  (>85% success rate в adaptive attacks, Jan 2026 meta-analysis)

## Decision

Принимаем следующие обязательные практики:

1. **Plan Mode для нетривиальных изменений**. Любое изменение >1 файла
   или в незнакомой области начинается с Plan Mode (Shift+Tab или /plan).
2. **TDD-цикл RED → GREEN → REFACTOR**. Тест ПЕРЕД кодом, минимальный
   код для прохождения, рефактор только при зелёных.
3. **Verification — обязательная фаза**. Любой PR должен включать способ
   автоматической верификации (тест, lint, type-check, screenshot).
4. **Manual /compact на 60% контекста**. Не ждать auto-compact на 83% —
   модель уже деградировала.
5. **/clear после двух неудачных коррекций подряд**. Контекст загрязнён,
   лучше переформулировать на чистую сессию.
6. **Subagents для исследования**. Любой grep/find по большой кодобазе —
   через subagent, чтобы не засорять основной контекст.
7. **Новые зависимости — через human review**. Проверка существования
   пакета на deps.dev/ecosys.dev, lockfile обновлён, `--ignore-scripts`
   для AI-driven installs.
8. **Pre-commit gitleaks обязателен**. Защита от случайного коммита
   секретов AI-ом.
9. **PR с AI-кодом — отдельный checklist**. См. `.github/pull_request_template.md`.
10. **Sandbox для autonomous runs**. Docker-контейнер или devcontainer
    для долгих автономных задач без надзора.

## Alternatives Considered

### Вариант A: Запретить AI-ассистенты полностью
- Плюсы: исключает классы рисков (slopsquatting, hallucinated APIs)
- Минусы: отказ от доказанного 2-5× speedup на greenfield/boilerplate
- Почему не выбран: запрет в эпоху повсеместного adopt — путь к shadow IT
  и обходу политик; лучше формализовать правила

### Вариант B: Использовать AI без правил
- Плюсы: меньше церемоний
- Минусы: подтверждено эмпирически — приводит к over-abstraction,
  снижению test coverage, накоплению технического долга
- Почему не выбран: DORA 2025 — "AI amplifies existing dysfunctions"

## Consequences

### Positive
- Конкретные правила вместо "будь осторожен с AI"
- Voltage rails для команды: новые члены сразу знают что можно и что нельзя
- Снижение типичных AI-related багов через структурные ограничения

### Negative
- Дополнительные церемонии (Plan Mode, /compact дисциплина) — overhead 5-10%
- Pre-commit hooks замедляют коммит на 5-30 секунд

### Risks
- Если правила не пересматриваются регулярно — устаревают (Claude Code
  v2.x → v3.x может изменить нормы)
- "Cargo cult compliance" без понимания — формальный TDD без бенефита

## References
- METR RCT: https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/
- DORA 2025: https://dora.dev/dora-report-2025/
- Best practices: https://code.claude.com/docs/en/best-practices
- Slopsquatting: https://www.trendmicro.com/vinfo/us/security/news/cybercrime-and-digital-threats/slopsquatting-when-ai-agents-hallucinate-malicious-packages
EOF
  print_substep "adr/0001-ai-assisted-development.md — стандарты AI-разработки"
fi

# ══════════════════════════════════════════════════════════════════════════════
# Quality Gates (Full only)
# ══════════════════════════════════════════════════════════════════════════════

if [ "$METHOD_LEVEL" -ge 3 ]; then
  print_step "Создаю Quality Gates..."

  cat > .claude/quality-gates/architecture-gate.md << 'EOF'
# Architecture Quality Gate

Перед переходом от планирования к реализации, проверь:

## Обязательные (все должны быть ✅)
- [ ] PRD.md заполнен полностью (все секции)
- [ ] PLANNING.md содержит архитектуру и обоснование стека
- [ ] Data model определена (сущности, связи, миграции)
- [ ] API design задокументирован (эндпоинты, контракты)
- [ ] Security model описана (auth, authz, encryption)
- [ ] TASKS.md содержит минимум Milestone 0 + Milestone 1
- [ ] Все задачи имеют зависимости
- [ ] Каждая задача "intern-sized" (1-4 часа)
- [ ] Тестовая стратегия определена (что покрываем, как)
- [ ] ADR создан для каждого нетривиального архитектурного решения

## Рекомендуемые
- [ ] Deployment strategy определена
- [ ] Monitoring/logging strategy определена
- [ ] Error handling strategy единообразна
- [ ] docs/ARCHITECTURE.md содержит системную диаграмму

## Scoring
- Обязательные: 10 пунктов × 10 = 100 баллов
- Рекомендуемые: 4 пункта × 5 = 20 бонусных баллов
- **Проходной балл: 90/100** (допускается 1 пропуск в обязательных)
EOF
  print_substep "architecture-gate.md (проходной балл: 90/100)"

  mkdir -p .claude/skills/gate-check
  cat > .claude/skills/gate-check/SKILL.md << 'EOF'
---
description: Quality Gate перед переходом от планирования к реализации. Проверяет 10 обязательных + 4 рекомендуемых пункта, требует ≥90/100 для GO. Используй когда нужно убедиться что планирование завершено.
allowed-tools: Read Bash(ls *) Bash(test*)
---

## Quality Gate checklist

Прочитай `.claude/quality-gates/architecture-gate.md` и для каждого пункта проверь:

1. Существует ли соответствующий документ/секция?
2. Заполнен ли он содержательно (не TODO/заглушка)?
3. Достаточно ли детализации для начала реализации?

## Скоринг

| Категория | Кол-во | Вес | Макс |
|-----------|--------|-----|------|
| Обязательные | 10 | 10 | 100 |
| Рекомендуемые | 4 | 5 | 20 |

**Проходной балл: 90/100** (допускается 1 пропуск в обязательных).

## Формат отчёта

```
Обязательные (10/10):
✅ PRD.md — заполнен (5 секций)
❌ Data model — только TODO в memory-bank/systemPatterns.md
...

Рекомендуемые (3/4):
✅ Deployment strategy
🔵 Monitoring — частично (только endpoints, нет метрик)
...

ИТОГО: 87/100 — NO-GO

Что доработать:
1. Заполнить data model в memory-bank/systemPatterns.md (10 баллов)
2. Добавить error handling strategy в PLANNING.md (5 баллов)
```

Если ≥90 — явно скажи "GO — готов к реализации". Не выдумывай зелёные оценки.
EOF
  print_substep "/gate-check — Skill для Quality Gate (≥90/100)"

  # Devcontainer для autonomous Claude runs (Full уровень)
  cat > .devcontainer/devcontainer.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/devcontainer.json",
  "name": "claude-code-sandbox",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu-24.04",
  "features": {
    "ghcr.io/devcontainers/features/node:1": { "version": "lts" },
    "ghcr.io/devcontainers/features/python:1": { "version": "3.12" },
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  },
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code && pip install pre-commit && pre-commit install",
  "customizations": {
    "vscode": {
      "extensions": [
        "anthropic.claude-code",
        "github.vscode-pull-request-github",
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "charliermarsh.ruff"
      ]
    }
  },
  "// Sandboxing notes": [
    "Этот devcontainer — изолированное окружение для autonomous Claude runs.",
    "Внутри контейнера можно безопасно использовать --permission-mode bypassPermissions",
    "(только! Никогда на host системе). См. Anthropic claude-code-sandboxing blog 2025."
  ]
}
EOF
  print_substep ".devcontainer/devcontainer.json — sandbox для autonomous runs"
fi

# ══════════════════════════════════════════════════════════════════════════════
# .gitignore
# ══════════════════════════════════════════════════════════════════════════════

print_step "Генерирую .gitignore..."

cat > .gitignore << 'EOF'
# Dependencies
node_modules/
.venv/
venv/
__pycache__/
*.pyc
*.pyo

# Environment / secrets
.env
.env.local
.env.*.local
.env.*
!.env.example
*.pem
*.key
*.p12
*.pfx
credentials/
secrets/

# Build
dist/
build/
.next/
out/
*.tsbuildinfo

# IDE
.idea/
.vscode/settings.json
.vscode/launch.json
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Claude Code — personal files (never commit)
CLAUDE.local.md
.claude/settings.local.json
.claude/.cache/
.claude/logs/

# Session artifacts (handoff archive)
_done/

# Logs
*.log
npm-debug.log*

# Test coverage
coverage/
.nyc_output/
EOF

print_substep ".gitignore создан"

# ══════════════════════════════════════════════════════════════════════════════
# Мастер-промпт для первого запуска
# ══════════════════════════════════════════════════════════════════════════════

print_step "Генерирую мастер-промпт для первого запуска Claude Code..."

cat > INIT_PROMPT.md << 'PROMPT_EOF'
# Первый запуск Claude Code в этом проекте

## Быстрый старт

```
/freshstart
```

Эта команда (skill) прочитает CLAUDE.md, memory-bank, TASKS.md, последний handoff
и git-состояние, и кратко доложит статус проекта.

## Полный workflow для greenfield-проекта

Если проект только что инициализирован и нужно его настроить с нуля,
вставь этот промпт в Claude Code (Shift+Tab → Plan Mode):

---

Ты начинаешь работу над свежеинициализированным проектом. Выполни поэтапно,
оставаясь в Plan Mode до явного перехода к реализации.

### Фаза 1: Ознакомление

1. Прочитай CLAUDE.md (главные инструкции)
2. Прочитай PRD.md, PLANNING.md, TASKS.md
3. Прочитай memory-bank/ — projectbrief, productContext, systemPatterns,
   techContext, activeContext, progress (если есть)
4. Прочитай .claude/rules/*.md (security, git, code-quality)
5. Кратко (5-7 строк) доложи что видишь и какие секции — заглушки TODO

### Фаза 2: Интервью + PRD

6. Задай мне 5-7 вопросов через AskUserQuestion (если доступно)
   о продукте: проблема, аудитория, метрики успеха, scope, ограничения
7. На основе ответов заполни PRD.md — все секции, без TODO

### Фаза 3: Архитектура

8. На основе PRD.md спланируй архитектуру:
   - Структура директорий с обоснованием
   - Основные компоненты и зависимости (текстовая диаграмма)
   - Data model (сущности, отношения)
   - API design (endpoints, контракты)
   - Запиши в PLANNING.md и docs/ARCHITECTURE.md

9. Для каждого нетривиального архитектурного решения — создай ADR:
   `/adr <тема решения>`

### Фаза 4: Декомпозиция задач

10. Разбей реализацию на Milestones (M0 Foundation, M1 MVP, M2+)
11. Каждая задача = 1-4 часа работы, чёткие критерии приёмки,
    зависимости между задачами явно указаны
12. Запиши в TASKS.md

### Фаза 5: Memory Bank

13. Обнови memory-bank/ — заполни projectbrief, productContext,
    systemPatterns, techContext

### Фаза 6: Quality Gate (только для уровня Full)

14. `/gate-check` — должен пройти ≥90/100
15. Если NO-GO — доработай и повтори

### Фаза 7: Реализация

16. Возьми TASK-001 из TASKS.md
17. `/plan <TASK-001>` → структурированный план
18. Switch out of Plan Mode (Shift+Tab) → `/implement <TASK-001>` (TDD)
19. По завершении задачи: `/code-review`, обнови TASKS.md и memory-bank
20. Перед закрытием сессии: `/handoff`

---

## Альтернатива: использовать Claude Code /init

Claude Code имеет built-in команду `/init` (с `CLAUDE_CODE_NEW_INIT=1`
доступен интерактивный multi-phase flow). Если CLAUDE.md уже создан
этим скриптом, /init предложит улучшения, а не перезапишет.

## Если возвращаешься к проекту через неделю+

Используй `/freshstart` — он сделает всё нужное автоматически.
PROMPT_EOF

print_substep "INIT_PROMPT.md — обновлён под Skills + новый workflow"

# ══════════════════════════════════════════════════════════════════════════════
# Pre-commit hooks — defence in depth (secret scanning + lint)
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю .pre-commit-config.yaml (gitleaks + lint)..."

cat > .pre-commit-config.yaml << 'EOF'
# Pre-commit hooks для дополнительной защиты (помимо Claude Code hooks).
# Install: pip install pre-commit && pre-commit install
# Update:  pre-commit autoupdate
#
# Зачем дублировать с Claude Code hooks?
# - Claude Code hooks работают только когда правит Claude
# - Pre-commit работает для ВСЕХ коммитов (включая ручные правки и других людей в команде)
# - Defence in depth: 2025 inсиденты (PromptMink npm malware via Claude, Shai-Hulud SAP CAP)
#   показали что нужна вторая линия защиты

repos:
  # ── Basic hygiene ────────────────────────────────────────────────────────
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-merge-conflict
      - id: check-added-large-files
        args: ['--maxkb=500']
      - id: check-yaml
      - id: check-json
      - id: check-toml
      - id: detect-private-key

  # ── Secret scanning (gitleaks) ───────────────────────────────────────────
  # Защита от случайной утечки секретов в коммиты, в т.ч. от AI-сгенерированных.
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2
    hooks:
      - id: gitleaks

  # ── Conventional commits ─────────────────────────────────────────────────
  - repo: https://github.com/compilerla/conventional-pre-commit
    rev: v3.6.0
    hooks:
      - id: conventional-pre-commit
        stages: [commit-msg]
        args: []
EOF

# Добавим stack-specific хуки если применимо
case "$PKG_MANAGER" in
  npm)
    cat >> .pre-commit-config.yaml << 'EOF'

  # ── JS/TS lint & format ──────────────────────────────────────────────────
  - repo: local
    hooks:
      - id: eslint
        name: eslint
        entry: npx eslint --fix
        language: system
        files: \.(ts|tsx|js|jsx)$
        pass_filenames: true
      - id: prettier
        name: prettier
        entry: npx prettier --write
        language: system
        files: \.(ts|tsx|js|jsx|json|md|yml|yaml)$
        pass_filenames: true
EOF
    ;;
  pip)
    cat >> .pre-commit-config.yaml << 'EOF'

  # ── Python lint & format ─────────────────────────────────────────────────
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.8.4
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
EOF
    ;;
esac

print_substep ".pre-commit-config.yaml — gitleaks + lint + conventional commits"

# ══════════════════════════════════════════════════════════════════════════════
# GitHub Actions — Claude Code review + CI baseline
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю GitHub Actions (CI + Claude Code review)..."

# Базовый CI workflow
cat > .github/workflows/ci.yml << CI_EOF
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install dependencies
        run: |
          # TODO: setup для вашего стека
          # Node: actions/setup-node@v4 + ${PKG_MANAGER} ci
          # Python: actions/setup-python@v5 + pip install -r requirements.txt
          echo "TODO: configure for your stack"
      - name: Lint
        run: ${LINT_CMD} || true  # TODO: убрать || true после первой зелёной сборки
      - name: Test
        run: ${TEST_CMD} || true  # TODO: убрать || true после первой зелёной сборки

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # gitleaks needs history
      - name: Gitleaks (secret scanning)
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
CI_EOF

# Claude Code review workflow (опциональный — требует ANTHROPIC_API_KEY)
cat > .github/workflows/claude-review.yml << 'CLAUDE_REVIEW_EOF'
name: Claude Code Review

# Автоматическое ревью PR через Claude Code в headless mode.
# Требует secret ANTHROPIC_API_KEY (Settings → Secrets → Actions).
# Стоимость: ~$0.05-0.20 на PR (зависит от размера diff и модели).
# Token budget: 20K на review (см. --output-format json для cost tracking).

on:
  pull_request:
    types: [opened, synchronize, reopened]
    paths-ignore:
      - '**/*.md'
      - 'docs/**'
      - '.github/**'

jobs:
  review:
    runs-on: ubuntu-latest
    if: github.event.pull_request.draft == false
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # для git diff main

      - name: Install Claude Code CLI
        run: npm install -g @anthropic-ai/claude-code

      - name: Run Claude review
        id: review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git diff origin/${{ github.base_ref }}...HEAD > /tmp/pr.diff
          if [ ! -s /tmp/pr.diff ]; then
            echo "No diff to review"
            exit 0
          fi

          # --bare для воспроизводимости (без локальных hooks/skills/MCP).
          # --output-format json для извлечения cost и result.
          cat /tmp/pr.diff | claude --bare -p "$(cat <<'PROMPT'
You are reviewing a pull request. The diff is in stdin.

Check for:
1. Correctness vs PR title
2. Security (secrets, injection, supply-chain)
3. AI-code antipatterns: over-abstraction, phantom dependencies, dropped defensive logic, unnecessary new files
4. Test coverage for new code

Output in this exact format:
🔴 BLOCKER (N): <file:line> — <issue> — <fix>
🟡 WARNING (M): <file:line> — <issue> — <fix>
🔵 SUGGESTION (K): <file:line> — <issue>

VERDICT: APPROVE | REQUEST CHANGES | NEEDS DISCUSSION

Be specific and concise. If no issues — say "VERDICT: APPROVE — no blockers, no warnings".
PROMPT
)" --output-format json --allowedTools "Read" > /tmp/review.json

          REVIEW=$(jq -r '.result' /tmp/review.json)
          COST=$(jq -r '.total_cost_usd // "?"' /tmp/review.json)

          {
            echo "## 🤖 Claude Code Review"
            echo ""
            echo "$REVIEW"
            echo ""
            echo "---"
            echo "<sub>Review cost: \$$COST · Generated by claude-code-forge</sub>"
          } > /tmp/comment.md

          gh pr comment "$PR_NUMBER" --body-file /tmp/comment.md
CLAUDE_REVIEW_EOF

print_substep ".github/workflows/ci.yml — test + gitleaks"
print_substep ".github/workflows/claude-review.yml — auto-review PR (требует ANTHROPIC_API_KEY)"

# PR template с AI-code checklist
cat > .github/pull_request_template.md << 'EOF'
## Summary

<!-- 1-3 bullet points: что и почему -->

## Test plan

<!-- Как проверить что работает: команды, шаги, expected output -->

- [ ] ...

## Checklist

### Общее
- [ ] Тесты добавлены/обновлены и зелёные
- [ ] Линтер зелёный
- [ ] CLAUDE.md обновлён (если изменились конвенции, build-команды, паттерны)
- [ ] ADR создан/обновлён (если принято нетривиальное архитектурное решение)
- [ ] Документация обновлена (если изменился публичный API)

### AI-generated code (если использовался Claude Code или другой агент)
- [ ] Self-review через `/code-review` пройден
- [ ] Не введено ненужных абстракций (Factory/Repository/Strategy для одного use case)
- [ ] Не удалена защитная логика (null checks, validation, rate limits, idempotency)
- [ ] Новые зависимости проверены на slopsquatting (deps.dev / ecosys.dev)
- [ ] Lockfile обновлён и зелёный (`npm ci` / `pip-compile`)
- [ ] Нет хардкода секретов (gitleaks pre-commit пройден)

### Безопасность (для security-sensitive изменений)
- [ ] `/security-audit` запущен — нет CRITICAL/HIGH
- [ ] User input валидируется на границе
- [ ] SQL параметризован, не concatenated
- [ ] CORS/CSP headers корректны
EOF

print_substep ".github/pull_request_template.md — AI-code review checklist"

# ══════════════════════════════════════════════════════════════════════════════
# Git init
# ══════════════════════════════════════════════════════════════════════════════

print_step "Инициализирую Git..."

# Явная ветка main, чтобы не зависеть от системного init.defaultBranch.
# Старые версии git (<2.28) не поддерживают -b, фолбэк через переименование.
if git init -q -b main 2>/dev/null; then
  :
else
  git init -q
  git symbolic-ref HEAD refs/heads/main 2>/dev/null || true
fi

# Проверка наличия git config user.name/user.email — без них commit упадёт молча.
if [ -z "$(git config --get user.name 2>/dev/null || true)" ] || \
   [ -z "$(git config --get user.email 2>/dev/null || true)" ]; then
  print_warning "git config user.name / user.email не настроены — первый коммит пропущен."
  print_warning "Настройте: git config user.name 'Your Name' && git config user.email 'you@example.com'"
  GIT_COMMIT_OK=0
else
  git add -A
  if git commit -q -m "chore: bootstrap project with Claude Code methodology (level ${METHOD_LEVEL})"; then
    GIT_COMMIT_OK=1
    print_substep "Первый коммит создан (ветка main)"
  else
    GIT_COMMIT_OK=0
    print_warning "git commit упал — проверьте состояние репозитория вручную."
  fi
fi

# ══════════════════════════════════════════════════════════════════════════════
# Итоговый отчёт
# ══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  ${GREEN}${BOLD}ПРОЕКТ УСПЕШНО СОЗДАН!${NC}                                     ${CYAN}║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Структура проекта:${NC}"
echo ""

# Показать дерево
if command -v tree &> /dev/null; then
  tree -a -I '.git|node_modules' --dirsfirst -L 3
else
  find . -not -path './.git/*' -not -path './.git' | head -60 | sort
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Следующие шаги:${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} Открой проект в VSCode:"
echo -e "     ${DIM}code ${PROJECT_NAME}${NC}"
echo ""
echo -e "  ${CYAN}2.${NC} Запусти Claude Code и вставь содержимое:"
echo -e "     ${DIM}cat INIT_PROMPT.md${NC}"
echo ""
echo -e "  ${CYAN}3.${NC} Или сразу выполни skill восстановления контекста:"
echo -e "     ${DIM}/freshstart${NC}"
echo ""
echo -e "  ${CYAN}4.${NC} Доступные skills (.claude/skills/):"
echo -e "     ${DIM}/freshstart${NC}              — старт сессии, восстановление контекста"
echo -e "     ${DIM}/plan <задача>${NC}           — Plan Mode с TDD-декомпозицией"
echo -e "     ${DIM}/implement <задача>${NC}      — TDD RED→GREEN→REFACTOR"
echo -e "     ${DIM}/code-review${NC}             — self-review с AI-checklist (BLOCKER/WARNING)"
echo -e "     ${DIM}/handoff${NC}                 — передать контекст следующей сессии"
echo -e "     ${DIM}/compact-save${NC}            — сохранить контекст до /compact (на 60%!)"
echo -e "     ${DIM}/security-audit${NC}          — аудит в forked-subagent (OWASP + supply chain)"
echo -e "     ${DIM}/commit${NC}                  — conventional commit с self-review"
if [ "$METHOD_LEVEL" -ge 2 ]; then
echo -e "     ${DIM}/adr <тема>${NC}              — создать Architecture Decision Record"
fi
if [ "$METHOD_LEVEL" -ge 3 ]; then
echo -e "     ${DIM}/gate-check${NC}              — проверка Quality Gate (≥90/100)"
fi
echo ""
echo -e "  ${CYAN}5.${NC} Specialized subagents (.claude/agents/) — Claude делегирует автоматически:"
echo -e "     ${DIM}code-reviewer${NC}            — isolated context, opus, для PR-review"
echo -e "     ${DIM}security-reviewer${NC}        — OWASP + supply chain focus"
echo -e "     ${DIM}test-writer${NC}              — TDD-first test generation"
echo ""
echo -e "  ${CYAN}6.${NC} Defence in depth:"
echo -e "     ${DIM}pre-commit install${NC}       — gitleaks + lint + conventional commits"
echo -e "     ${DIM}gh secret set ANTHROPIC_API_KEY${NC} — включить .github/workflows/claude-review.yml"
echo ""
echo -e "${BOLD}Workflow (Anthropic-recommended, Best Practices 2026):${NC}"
echo -e "  ${DIM}Explore (Plan Mode) → Plan → Implement (TDD) → Verify → Commit${NC}"
echo -e "  ${DIM}/compact на 60% контекста · /clear после двух коррекций подряд${NC}"
echo ""

if [ "${GIT_COMMIT_OK:-0}" -eq 0 ]; then
  print_warning "Первый git-коммит не был создан (см. предыдущие предупреждения)."
fi
if [ "$JQ_AVAILABLE" -eq 0 ]; then
  print_warning "jq не установлен — хуки Claude Code (auto-format, защита от опасных команд) не будут работать."
  print_warning "Установите: apt install jq | brew install jq"
fi
if ! command -v pre-commit >/dev/null 2>&1; then
  print_warning "pre-commit не установлен. Защита от утечки секретов через gitleaks не активна."
  print_warning "Установите: pip install pre-commit && pre-commit install"
fi
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${DIM}Методология: Structured Development with Claude Code v3.0 (2026 standards)${NC}"
echo -e "${DIM}Уровень: ${METHOD_LEVEL} (1=Minimal, 2=Standard, 3=Full)${NC}"
echo -e "${DIM}Source: code.claude.com/docs/en + Anthropic Best Practices + DORA 2025 + METR RCT${NC}"
echo ""
