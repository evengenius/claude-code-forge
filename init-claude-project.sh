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

# ── Locate script directory (resolves symlinks) ──────────────────────────────
FORGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Colors and formatting ────────────────────────────────────────────────────
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

# ── Load core functions ──────────────────────────────────────────────────────
# shellcheck source=src/core.sh
source "${FORGE_DIR}/src/core.sh"

# ── Interactive input ────────────────────────────────────────────────────────

print_header

# Project name
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
  1) source "${FORGE_DIR}/src/stacks/nextjs.sh" ;;
  2) source "${FORGE_DIR}/src/stacks/react-vite.sh" ;;
  3) source "${FORGE_DIR}/src/stacks/node-express.sh" ;;
  4) source "${FORGE_DIR}/src/stacks/python-fastapi.sh" ;;
  5) source "${FORGE_DIR}/src/stacks/custom.sh" ;;
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

# ── Run ──────────────────────────────────────────────────────────────────────

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

create_directories
generate_all_files
init_git
print_summary
