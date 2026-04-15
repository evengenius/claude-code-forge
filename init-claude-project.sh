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

# Базовые директории (все уровни)
mkdir -p .claude/commands
mkdir -p .claude/rules
mkdir -p docs
mkdir -p src

# Standard+ директории
if [ "$METHOD_LEVEL" -ge 2 ]; then
  mkdir -p .claude/skills
  mkdir -p memory-bank
  mkdir -p adr
  mkdir -p _todo
  mkdir -p _done
fi

# Full директории
if [ "$METHOD_LEVEL" -ge 3 ]; then
  mkdir -p .claude/quality-gates
  mkdir -p specs
fi

print_substep "Структура директорий создана"

# ══════════════════════════════════════════════════════════════════════════════
# CLAUDE.md — главный файл инструкций
# ══════════════════════════════════════════════════════════════════════════════

print_step "Генерирую CLAUDE.md..."

cat > CLAUDE.md << 'CLAUDE_EOF'
# Project: __PROJECT_NAME__

__PROJECT_DESC__

## Tech Stack
- __TECH_STACK__
- Tests: __TEST_FRAMEWORK__

## Build & Run
- `__DEV_CMD__` — dev server
- `__BUILD_CMD__` — production build
- `__TEST_CMD__` — run tests
- `__LINT_CMD__` — lint + format

## Architecture
- TODO: Описать архитектуру после первой сессии планирования
- Паттерн: [Repository → Service → Controller / иной]

## Key Conventions
- ESM modules (import/export), NOT CommonJS
- Файлы тестов: `*.test.ts` / `*.test.py` рядом с тестируемым файлом
- Коммиты: conventional commits (feat:, fix:, refactor:, docs:, test:, chore:)
- Ветки: feature/*, bugfix/*, hotfix/*

## Development Workflow
- ВСЕГДА Test-Driven Development: RED → GREEN → REFACTOR
- Plan Mode (Shift+Tab) ПЕРЕД реализацией для задач >30 минут
- Один `/compact` при 60-80% контекста с описанием что сохранить
- Handoff-документ в конце каждой сессии

## Common Gotchas
- TODO: Заполняется итеративно по мере обнаружения проблем

## Reference Documents
- @docs/ARCHITECTURE.md — архитектурный обзор
- @PLANNING.md — стратегия и процесс
- @TASKS.md — текущие задачи
CLAUDE_EOF

# Подстановка переменных (совместимо с macOS и Linux)
replace_in_file() {
  local pattern="$1" file="$3"
  # Escape & in replacement (special char in sed)
  local replacement
  replacement=$(printf '%s' "$2" | sed 's/&/\\&/g')
  if sed --version >/dev/null 2>&1; then
    sed -i "s|${pattern}|${replacement}|g" "$file"
  else
    sed -i '' "s|${pattern}|${replacement}|g" "$file"
  fi
}

replace_in_file "__PROJECT_NAME__" "${PROJECT_NAME}" CLAUDE.md
replace_in_file "__PROJECT_DESC__" "${PROJECT_DESC}" CLAUDE.md
replace_in_file "__TECH_STACK__" "${TECH_STACK}" CLAUDE.md
replace_in_file "__TEST_FRAMEWORK__" "${TEST_FRAMEWORK}" CLAUDE.md
replace_in_file "__DEV_CMD__" "${DEV_CMD}" CLAUDE.md
replace_in_file "__BUILD_CMD__" "${BUILD_CMD}" CLAUDE.md
replace_in_file "__TEST_CMD__" "${TEST_CMD}" CLAUDE.md
replace_in_file "__LINT_CMD__" "${LINT_CMD}" CLAUDE.md

# Добавить ссылки на memory bank и ADR для Standard+
if [ "$METHOD_LEVEL" -ge 2 ]; then
  cat >> CLAUDE.md << 'EOF'

## Memory Bank
- @memory-bank/ — персистентная память проекта (читать в начале каждой задачи)

## Architecture Decision Records
- See /adr/ for detailed decisions (заполняется по мере принятия решений)
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

cat > .claude/settings.json << SETTINGS_EOF
{
  "permissions": {
    "allow": [
      "Read(**/*)",
      "Edit(**/*)",
      "Write(**/*)",
      "Bash(${PKG_MANAGER} *)",
      "Bash(git *)",
      "Bash(${TEST_CMD}*)",
      "Bash(npx *)",
      "Bash(node *)",
      "Bash(cat *)",
      "Bash(ls *)",
      "Bash(find *)",
      "Bash(grep *)",
      "Bash(head *)",
      "Bash(tail *)",
      "Bash(wc *)",
      "Bash(mkdir *)",
      "Bash(cp *)",
      "Bash(mv *)"
    ],
    "deny": [
      "Read(.env*)",
      "Read(**/*.pem)",
      "Read(**/*.key)",
      "Read(**/credentials/**)",
      "Read(**/secrets/**)",
      "Read(**/.ssh/**)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(rm -rf /)*",
      "Bash(*--force*main*)",
      "Bash(sudo *)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "${FORMAT_CMD} \"\$CLAUDE_FILE_PATH\" 2>/dev/null || true"
      },
      {
        "matcher": "Edit|Write",
        "command": "${LINT_FILE_CMD} \"\$CLAUDE_FILE_PATH\" 2>/dev/null || true"
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "command": "if echo \"\$CLAUDE_BASH_COMMAND\" | grep -qE 'rm -rf /|git push.*--force.*main|DROP TABLE|DROP DATABASE'; then echo 'BLOCKED: potentially destructive command' >&2; exit 1; fi"
      }
    ],
    "Stop": [
      {
        "command": "${TEST_CMD} 2>&1 | tail -30 || true"
      }
    ]
  }
}
SETTINGS_EOF

print_substep "Permissions настроены (deny: .env, .pem, .key, secrets)"
print_substep "PostToolUse хуки: auto-format + auto-lint"
print_substep "PreToolUse хук: блокировка деструктивных команд"
print_substep "Stop хук: автозапуск тестов при завершении задачи"

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

# Lock files (шум в контексте)
package-lock.json
yarn.lock
pnpm-lock.yaml
poetry.lock

# Archives
*.zip
*.tar.gz
*.rar

# Done tasks
_done/
EOF

print_substep ".claudeignore создан"

# ══════════════════════════════════════════════════════════════════════════════
# Кастомные команды
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю кастомные slash-команды..."

# /project:plan — планирование задачи с учётом ADR
cat > .claude/commands/plan.md << 'EOF'
Спланируй реализацию задачи. Следуй процессу:

1. Прочитай CLAUDE.md, PLANNING.md и TASKS.md
2. Прочитай memory-bank/activeContext.md и memory-bank/progress.md
3. Прочитай список ADR из /adr/ (если есть)
4. Проанализируй задачу: $ARGUMENTS
5. Используй Plan Mode (НЕ вноси изменений):
   - Определи затронутые файлы и модули
   - Оцени impact на существующий код
   - Предложи подход с обоснованием
   - Определи тесты, которые нужно написать ПЕРВЫМИ
   - Оцени размер задачи (S/M/L/XL)
6. Если задача XL — разбей на подзадачи размером S-M
7. Если подход противоречит существующему ADR — укажи это
8. Если нужен новый ADR — спроси подтверждения

Результат: структурированный план с шагами, файлами, тестами и рисками.
EOF
print_substep "/project:plan — планирование с учётом ADR"

# /project:implement — реализация по TDD
cat > .claude/commands/implement.md << 'EOF'
Реализуй задачу по TDD-циклу. Строго следуй процессу:

1. Прочитай план задачи (если нет — сначала выполни /project:plan)
2. Для каждого шага плана:
   a. RED: Напиши ОДИН падающий тест. Запусти — убедись что падает.
   b. GREEN: Напиши МИНИМАЛЬНЫЙ код для прохождения теста. Запусти — убедись что проходит.
   c. REFACTOR: Улучши код, сохраняя зелёные тесты. Запусти тесты.
3. После завершения всех шагов:
   - Запусти полный тест-сьют
   - Обнови TASKS.md (отметь выполненное)
   - Обнови memory-bank/activeContext.md
4. ЗАПРЕЩЕНО: менять тесты чтобы они проходили, пропускать RED-фазу, реализовывать без теста.

Задача: $ARGUMENTS
EOF
print_substep "/project:implement — TDD-реализация"

# /project:handoff — передача контекста
cat > .claude/commands/handoff.md << 'EOF'
Создай handoff-документ для передачи контекста следующей сессии.

Напиши файл _todo/handoff-YYYY-MM-DD.md со структурой:

# Session Handoff — [дата]

## Цель сессии
Что планировалось сделать

## Что сделано
- Конкретный список выполненных задач с файлами

## Ключевые решения
- Решения и их обоснования (кандидаты для ADR)

## Тупики и отвергнутые подходы
- Что попробовали и почему не сработало

## Текущий статус
- Что работает, что сломано, что в процессе

## Следующие шаги (приоритет)
1. Первоочередная задача
2. ...

## Активные файлы
- Список файлов, с которыми работали

## Контекст для отладки
- Ошибки, которые видели, и как их решали

Также обнови:
- memory-bank/activeContext.md
- memory-bank/progress.md
- TASKS.md
EOF
print_substep "/project:handoff — передача контекста между сессиями"

# /project:review — ревью кода
cat > .claude/commands/review.md << 'EOF'
Проведи code review изменений. Процесс:

1. Выполни `git diff --stat` чтобы увидеть изменённые файлы
2. Для каждого файла проверь:
   - Корректность бизнес-логики
   - Обработка ошибок и edge cases
   - Безопасность (нет хардкода секретов, SQL injection, XSS)
   - Производительность (нет N+1 запросов, утечек памяти)
   - Тестовое покрытие (каждый публичный метод покрыт)
   - Соответствие архитектурным паттернам из CLAUDE.md
   - Соответствие ADR (если применимо)
3. Классифицируй замечания:
   - 🔴 BLOCKER — нельзя мержить
   - 🟡 WARNING — желательно исправить
   - 🔵 SUGGESTION — можно улучшить позже
4. Предложи конкретные исправления для BLOCKER и WARNING

Скоуп ревью: $ARGUMENTS
EOF
print_substep "/project:review — ревью кода"

# /project:freshstart — начало новой сессии
cat > .claude/commands/freshstart.md << 'EOF'
Начало новой рабочей сессии. Выполни:

1. Прочитай CLAUDE.md
2. Прочитай memory-bank/ (все 6 файлов)
3. Прочитай TASKS.md
4. Проверь наличие handoff в _todo/ — прочитай последний
5. Выполни `git log --oneline -10` для контекста последних изменений
6. Выполни `git status` для текущего состояния
7. Кратко доложи:
   - Текущий статус проекта
   - Последние выполненные задачи
   - Рекомендуемая следующая задача (из TASKS.md с учётом зависимостей)
   - Потенциальные проблемы
EOF
print_substep "/project:freshstart — восстановление контекста"

# /project:compact-save — безопасное сжатие
cat > .claude/commands/compact-save.md << 'EOF'
Подготовка к компакции контекста. Перед вызовом /compact:

1. Обнови memory-bank/activeContext.md с текущим состоянием
2. Обнови memory-bank/progress.md
3. Запиши в _todo/session-notes.md любые важные детали, которые могут потеряться:
   - Отвергнутые подходы и почему
   - Неочевидные зависимости между файлами
   - Баги, которые видели но не починили
   - Промежуточные результаты отладки
4. Сообщи, что можно безопасно вызвать: /compact [рекомендуемая инструкция]
EOF
print_substep "/project:compact-save — безопасная компакция"

# /project:adr — создание ADR
if [ "$METHOD_LEVEL" -ge 2 ]; then
cat > .claude/commands/adr.md << 'EOF'
Создай Architecture Decision Record. Процесс:

1. Прочитай существующие ADR в /adr/ для контекста
2. Определи следующий номер (NNN)
3. Создай файл adr/NNN-[slug].md:

# ADR-NNN: [Заголовок решения]

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-XXX

## Context
Какая проблема или необходимость привела к этому решению?

## Decision
Что именно решили и почему?

## Alternatives Considered
### Вариант A: [название]
- Плюсы: ...
- Минусы: ...

### Вариант B: [название]
- Плюсы: ...
- Минусы: ...

## Consequences
### Positive
- ...
### Negative
- ...
### Risks
- ...

4. Добавь ссылку в CLAUDE.md секцию "Architecture Decision Records"
5. Обнови memory-bank/systemPatterns.md

Тема решения: $ARGUMENTS
EOF
print_substep "/project:adr — создание Architecture Decision Record"
fi

# /project:security-audit
cat > .claude/commands/security-audit.md << 'EOF'
Проведи аудит безопасности. Проверь:

1. **Секреты**: `grep -rn "password\|secret\|api_key\|token\|private" src/ --include="*.ts" --include="*.py" --include="*.js"`
2. **Хардкод URL/IP**: `grep -rn "http://\|https://\|[0-9]\{1,3\}\.[0-9]\{1,3\}" src/`
3. **SQL injection**: raw SQL queries без параметризации
4. **XSS**: dangerouslySetInnerHTML, непроэскейпленный вывод
5. **Зависимости**: `npm audit` или `pip audit`
6. **Permissions**: файлы с 777, исполняемые скрипты
7. **.env в git**: `git log --all --full-history -- ".env*"`
8. **CORS**: чрезмерно широкие настройки
9. **Auth**: токены без expiry, отсутствие rate limiting

Для каждого найденного — severity (CRITICAL/HIGH/MEDIUM/LOW) и конкретное исправление.

Скоуп: $ARGUMENTS
EOF
print_substep "/project:security-audit — аудит безопасности"

# ══════════════════════════════════════════════════════════════════════════════
# Модульные правила (.claude/rules/)
# ══════════════════════════════════════════════════════════════════════════════

print_step "Создаю модульные правила..."

cat > .claude/rules/testing.md << 'EOF'
---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "**/tests/**"
  - "**/__tests__/**"
---
# Testing Rules
- НИКОГДА не модифицируй тест, чтобы он проходил с текущей реализацией
- Каждый тест проверяет ОДНО поведение (один assert на семантику)
- Именование: `should [expected behavior] when [condition]`
- Обязательно: happy path + минимум 2 edge case + 1 error case
- Моки: только для внешних зависимостей (API, DB), НЕ для внутренних модулей
EOF
print_substep "testing.md — правила тестирования"

cat > .claude/rules/security.md << 'EOF'
# Security Rules (загружаются всегда)
- НИКОГДА не хардкодить секреты, пароли, API-ключи, токены
- Все секреты — через переменные окружения
- SQL: ТОЛЬКО параметризованные запросы
- Пользовательский ввод: ВСЕГДА валидировать и санитизировать
- CORS: минимально необходимый набор origins
- HTTP: проверять Content-Type, использовать helmet/security headers
- Логирование: НИКОГДА не логировать секреты, пароли, токены, PII
EOF
print_substep "security.md — правила безопасности"

cat > .claude/rules/git.md << 'EOF'
# Git Rules (загружаются всегда)
- Коммиты: conventional commits (feat:, fix:, refactor:, docs:, test:, chore:)
- Один коммит = одно логическое изменение
- НЕ коммитить: сгенерированные файлы, node_modules, .env, билд-артефакты
- Перед коммитом: запустить тесты + линтер
- Branch naming: feature/*, bugfix/*, hotfix/*
EOF
print_substep "git.md — правила Git"

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
4. Code review через /project:review
5. Handoff через /project:handoff в конце сессии
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
  cat > adr/000-template.md << 'EOF'
# ADR-NNN: [Заголовок]

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-XXX

## Context
Какая проблема или необходимость привела к этому решению?

## Decision
Что решили и почему?

## Alternatives Considered
### Вариант A
- Плюсы: ...
- Минусы: ...

## Consequences
### Positive
- ...
### Negative
- ...
EOF
  print_substep "adr/000-template.md"
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

  cat > .claude/commands/gate-check.md << 'EOF'
Проведи проверку Quality Gate.

1. Прочитай .claude/quality-gates/architecture-gate.md
2. Для каждого пункта чек-листа проверь:
   - Существует ли соответствующий документ/секция?
   - Заполнен ли он содержательно (не TODO)?
   - Достаточно ли детализации для начала реализации?
3. Выставь оценку: ✅ (10 баллов) / ❌ (0 баллов) для каждого
4. Подсчитай итоговый балл
5. Если < 90: перечисли что нужно доработать
6. Если ≥ 90: подтверди готовность к реализации

Результат: таблица с оценками + итоговый вердикт GO/NO-GO
EOF
  print_substep "/project:gate-check — проверка качественных ворот"
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

# Environment
.env
.env.local
.env.*.local

# Build
dist/
build/
.next/
out/

# IDE
.idea/
.vscode/settings.json
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Claude Code personal
CLAUDE.local.md

# Session artifacts
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
# Мастер-промпт: Первый запуск Claude Code

Скопируй этот промпт в Claude Code при первом запуске в проекте.

---

Ты начинаешь работу над новым проектом, который уже инициализирован по структурированной методологии. Выполни следующее:

## Фаза 1: Ознакомление (Plan Mode)

1. Прочитай CLAUDE.md — это твои главные инструкции
2. Прочитай PRD.md, PLANNING.md, TASKS.md
3. Если есть memory-bank/ — прочитай все 6 файлов
4. Выполни `ls -la` и `find src/ -type f` для понимания текущей структуры
5. Кратко доложи что видишь и что нужно заполнить

## Фаза 2: Планирование (оставайся в Plan Mode)

6. Помоги мне заполнить PRD.md:
   - Задай мне 5-7 ключевых вопросов о продукте
   - На основе ответов заполни все секции PRD.md

7. На основе PRD.md спланируй архитектуру:
   - Предложи структуру директорий
   - Определи основные компоненты и их связи
   - Определи data model
   - Запиши в PLANNING.md

8. Декомпозируй на задачи:
   - Разбей реализацию на Milestones
   - Каждая задача = 1-4 часа, с чёткими критериями приёмки
   - Определи зависимости между задачами
   - Запиши в TASKS.md

9. Для каждого нетривиального решения — создай ADR в /adr/

10. Обнови memory-bank/ со всей информацией из планирования

## Фаза 3: Quality Gate (если уровень Full)

11. Выполни /project:gate-check
12. Если NO-GO — доработай недостающее
13. Если GO — переходи к реализации

## Фаза 4: Начало реализации

14. Возьми TASK-001 из TASKS.md
15. Следуй TDD: RED → GREEN → REFACTOR
16. После завершения — обнови TASKS.md и memory-bank/progress.md

---

Начни с Фазы 1. Расскажи что видишь.
PROMPT_EOF

print_substep "INIT_PROMPT.md — мастер-промпт для первого запуска"

# ══════════════════════════════════════════════════════════════════════════════
# Git init
# ══════════════════════════════════════════════════════════════════════════════

print_step "Инициализирую Git..."

git init -q
git add -A
git commit -q -m "chore: bootstrap project with Claude Code methodology (level ${METHOD_LEVEL})" 2>/dev/null || \
  print_warning "Git commit пропущен (настройте git config user.name / user.email)"

print_substep "Первый коммит создан"

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
echo -e "  ${CYAN}3.${NC} Или используй slash-команду:"
echo -e "     ${DIM}/project:freshstart${NC}"
echo ""
echo -e "  ${CYAN}4.${NC} Доступные команды:"
echo -e "     ${DIM}/project:plan [задача]${NC}      — спланировать задачу"
echo -e "     ${DIM}/project:implement [задача]${NC} — реализовать по TDD"
echo -e "     ${DIM}/project:handoff${NC}            — передать контекст"
echo -e "     ${DIM}/project:review${NC}             — code review"
echo -e "     ${DIM}/project:compact-save${NC}       — безопасная компакция"
echo -e "     ${DIM}/project:security-audit${NC}     — аудит безопасности"
if [ "$METHOD_LEVEL" -ge 2 ]; then
echo -e "     ${DIM}/project:adr [тема]${NC}         — создать ADR"
fi
if [ "$METHOD_LEVEL" -ge 3 ]; then
echo -e "     ${DIM}/project:gate-check${NC}         — проверка Quality Gate"
fi
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${DIM}Методология: Structured Development with Claude Code v2.0${NC}"
echo -e "${DIM}Уровень: ${METHOD_LEVEL} (1=Minimal, 2=Standard, 3=Full)${NC}"
echo ""
