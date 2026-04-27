#!/usr/bin/env bash
# ============================================================================
# CLAUDE CODE PROJECT BOOTSTRAP v2.1
# Полная инициализация проекта по методологии структурированной разработки
# с Claude Code (VSCode + Pro subscription)
#
# Использование:
#   chmod +x init-claude-project.sh
#   ./init-claude-project.sh [имя-проекта]
#
# Или с интерактивным вводом:
#   ./init-claude-project.sh
#
# Флаги:
#   --in-place       инициализировать в текущей директории, без создания подпапки
#   --monorepo       создать монорепозиторий (apps/* + packages/*) вместо одного src/
#   --tier <1..4>    1=Minimal, 2=Standard, 3=Full, 4=App; пропускает интерактивный выбор
#   --stack <name>   nextjs|react-vite|node-express|python-fastapi|tauri-sveltekit|expo-rn|hono-workers|custom
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
  echo -e "${CYAN}║${NC}  ${DIM}Structured Development Methodology v2.1${NC}                     ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

print_step()    { echo -e "${GREEN}[✓]${NC} ${BOLD}$1${NC}"; }
print_substep() { echo -e "    ${DIM}└─${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error()   { echo -e "${RED}[✗]${NC} $1"; }

# ── Defaults / flags ─────────────────────────────────────────────────────────
IN_PLACE=0
MONOREPO=0
PROJECT_NAME=""
METHOD_LEVEL=""
STACK_PRESET=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --in-place) IN_PLACE=1; shift ;;
    --monorepo) MONOREPO=1; shift ;;
    --tier)     METHOD_LEVEL="$2"; shift 2 ;;
    --stack)    STACK_PRESET="$2"; shift 2 ;;
    --*)        print_error "Неизвестный флаг: $1"; exit 1 ;;
    *)          if [ -z "$PROJECT_NAME" ]; then PROJECT_NAME="$1"; shift; else shift; fi ;;
  esac
done

export MONOREPO

# ── Load core functions ──────────────────────────────────────────────────────
# shellcheck source=src/core.sh
source "${FORGE_DIR}/src/core.sh"

# ── Interactive input ────────────────────────────────────────────────────────

print_header

# Project name
if [ -z "$PROJECT_NAME" ]; then
  if [ "$IN_PLACE" -eq 1 ]; then
    PROJECT_NAME="$(basename "$PWD")"
  else
    echo -e "${BOLD}Введите имя проекта:${NC}"
    read -r PROJECT_NAME
  fi
fi

if [ -z "$PROJECT_NAME" ]; then
  print_error "Имя проекта не может быть пустым"
  exit 1
fi

echo -e "${BOLD}Краткое описание проекта (1-2 предложения):${NC}"
read -r PROJECT_DESC
PROJECT_DESC="${PROJECT_DESC:-Описание проекта}"

# Stack
if [ -z "$STACK_PRESET" ]; then
  echo ""
  echo -e "${BOLD}Выберите тех-стек:${NC}"
  echo "  1) Next.js + TypeScript + Prisma + PostgreSQL"
  echo "  2) React + TypeScript + Vite"
  echo "  3) Node.js + Express + TypeScript"
  echo "  4) Python + FastAPI"
  echo "  5) Tauri 2 + SvelteKit (cross-platform: Web/Desktop/Mobile)"
  echo "  6) Expo + React Native + Next.js (universal mobile/web via Tamagui)"
  echo "  7) Hono + Cloudflare Workers + Drizzle (edge backend)"
  echo "  8) Кастомный (ввести вручную)"
  read -r STACK_CHOICE

  case "${STACK_CHOICE:-1}" in
    1) STACK_PRESET="nextjs" ;;
    2) STACK_PRESET="react-vite" ;;
    3) STACK_PRESET="node-express" ;;
    4) STACK_PRESET="python-fastapi" ;;
    5) STACK_PRESET="tauri-sveltekit" ;;
    6) STACK_PRESET="expo-rn" ;;
    7) STACK_PRESET="hono-workers" ;;
    8) STACK_PRESET="custom" ;;
    *)  print_error "Неверный выбор"; exit 1 ;;
  esac
fi

if [ ! -f "${FORGE_DIR}/src/stacks/${STACK_PRESET}.sh" ]; then
  print_error "Стек '${STACK_PRESET}' не найден в src/stacks/"
  exit 1
fi
# shellcheck source=/dev/null
source "${FORGE_DIR}/src/stacks/${STACK_PRESET}.sh"

# Methodology level
if [ -z "$METHOD_LEVEL" ]; then
  echo ""
  echo -e "${BOLD}Уровень методологии:${NC}"
  echo "  1) Minimal  — CLAUDE.md + handoff + хуки (соло-проекты, MVP)"
  echo "  2) Standard — + memory bank + ADR + TDD + команды (средние проекты)"
  echo "  3) Full     — + BMAD-совместимая структура + качественные ворота (enterprise)"
  echo "  4) App      — + offline-first / cross-platform / a11y / perf / privacy gates (consumer apps)"
  read -r METHOD_LEVEL
  METHOD_LEVEL="${METHOD_LEVEL:-2}"
fi

if [[ ! "$METHOD_LEVEL" =~ ^[1-4]$ ]]; then
  print_error "Неверный уровень: $METHOD_LEVEL (должно быть 1..4)"
  exit 1
fi

# Monorepo (interactive if not set)
if [ "$MONOREPO" -eq 0 ] && [ -z "${SKIP_MONOREPO_PROMPT:-}" ]; then
  echo ""
  echo -e "${BOLD}Монорепозиторий?${NC} (apps/* + packages/* для проектов с несколькими таргетами)"
  echo "  1) Нет, single-package (по умолчанию)"
  echo "  2) Да, monorepo (pnpm workspaces)"
  read -r MR_CHOICE
  MR_CHOICE="${MR_CHOICE:-1}"
  if [ "$MR_CHOICE" = "2" ]; then MONOREPO=1; fi
fi
export MONOREPO

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}Создаю проект:${NC} $PROJECT_NAME"
echo -e "${BOLD}Стек:${NC} $TECH_STACK"
echo -e "${BOLD}Уровень:${NC} $METHOD_LEVEL"
echo -e "${BOLD}Monorepo:${NC} $([ "$MONOREPO" -eq 1 ] && echo "Yes" || echo "No")"
echo -e "${BOLD}In-place:${NC} $([ "$IN_PLACE" -eq 1 ] && echo "Yes" || echo "No")"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# ── Run ──────────────────────────────────────────────────────────────────────

if [ "$IN_PLACE" -eq 0 ]; then
  mkdir -p "$PROJECT_NAME"
  cd "$PROJECT_NAME"
fi

create_directories
generate_all_files
init_git
print_summary
