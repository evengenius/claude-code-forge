#!/usr/bin/env bash
# ============================================================================
# core.sh — Core functions for Claude Code Project Bootstrap (v2.1)
# Handles: directory creation, template rendering, settings generation,
#          git initialization, and summary output.
# ============================================================================

# Resolve the directory where this file lives so templates can be found
# regardless of where the entry point script is called from.
FORGE_SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORGE_TEMPLATES_DIR="${FORGE_SRC_DIR}/templates"

# ── Template variable substitution ──────────────────────────────────────────

# replace_in_file <placeholder> <value> <file>
# Cross-platform sed: supports both GNU (Linux/WSL/Git-Bash) and BSD (macOS).
replace_in_file() {
  local pattern="$1" file="$3"
  local replacement
  replacement=$(printf '%s' "$2" | sed 's/[&/]/\\&/g')
  if sed --version >/dev/null 2>&1; then
    sed -i "s|${pattern}|${replacement}|g" "$file"
  else
    sed -i '' "s|${pattern}|${replacement}|g" "$file"
  fi
}

generate_from_template() {
  local src="$1" dst="$2"
  cp "$src" "$dst"
  replace_in_file "__PROJECT_NAME__"   "${PROJECT_NAME}"    "$dst"
  replace_in_file "__PROJECT_DESC__"   "${PROJECT_DESC}"    "$dst"
  replace_in_file "__TECH_STACK__"     "${TECH_STACK}"      "$dst"
  replace_in_file "__TEST_FRAMEWORK__" "${TEST_FRAMEWORK}"  "$dst"
  replace_in_file "__DEV_CMD__"        "${DEV_CMD}"         "$dst"
  replace_in_file "__BUILD_CMD__"      "${BUILD_CMD}"       "$dst"
  replace_in_file "__TEST_CMD__"       "${TEST_CMD}"        "$dst"
  replace_in_file "__LINT_CMD__"       "${LINT_CMD}"        "$dst"
  replace_in_file "__FORMAT_CMD__"     "${FORMAT_CMD}"      "$dst"
  replace_in_file "__LINT_FILE_CMD__"  "${LINT_FILE_CMD}"   "$dst"
  replace_in_file "__PKG_MANAGER__"    "${PKG_MANAGER}"     "$dst"
  replace_in_file "__METHOD_LEVEL__"   "${METHOD_LEVEL}"    "$dst"
}

# ── Directory structure ──────────────────────────────────────────────────────

create_directories() {
  print_step "Создаю структуру директорий..."

  mkdir -p .claude/commands
  mkdir -p .claude/rules
  mkdir -p .claude/agents
  mkdir -p docs

  if [ "${MONOREPO:-0}" -eq 1 ]; then
    mkdir -p apps/web apps/desktop apps/mobile
    mkdir -p packages/core packages/db packages/ui packages/config packages/sync
  else
    mkdir -p src
  fi

  if [ "$METHOD_LEVEL" -ge 2 ]; then
    mkdir -p memory-bank adr _todo _done
  fi

  if [ "$METHOD_LEVEL" -ge 3 ]; then
    mkdir -p .claude/quality-gates
    mkdir -p specs
  fi

  print_substep "Структура директорий создана"
}

# ── File generation ──────────────────────────────────────────────────────────

generate_all_files() {
  local tpl="${FORGE_TEMPLATES_DIR}"

  # ── CLAUDE.md ──
  print_step "Генерирую CLAUDE.md..."
  generate_from_template "${tpl}/base/CLAUDE.md.tpl" CLAUDE.md
  if [ "$METHOD_LEVEL" -ge 2 ]; then
    cat "${tpl}/base/CLAUDE.md.standard-append.tpl" >> CLAUDE.md
  fi
  print_substep "CLAUDE.md создан"

  # ── CLAUDE.local.md ──
  print_step "Генерирую CLAUDE.local.md..."
  generate_from_template "${tpl}/base/CLAUDE.local.md.tpl" CLAUDE.local.md
  print_substep "CLAUDE.local.md создан"

  # ── .claude/settings.json ──
  generate_settings_json

  # ── .claudeignore ──
  print_step "Генерирую .claudeignore..."
  cp "${tpl}/base/claudeignore.tpl" .claudeignore
  print_substep ".claudeignore создан"

  # ── Slash commands ──
  print_step "Создаю кастомные slash-команды..."
  cp "${tpl}/commands/plan.md"           .claude/commands/plan.md
  cp "${tpl}/commands/implement.md"      .claude/commands/implement.md
  cp "${tpl}/commands/handoff.md"        .claude/commands/handoff.md
  cp "${tpl}/commands/review.md"         .claude/commands/review.md
  cp "${tpl}/commands/freshstart.md"     .claude/commands/freshstart.md
  cp "${tpl}/commands/compact-save.md"   .claude/commands/compact-save.md
  cp "${tpl}/commands/security-audit.md" .claude/commands/security-audit.md
  cp "${tpl}/commands/metrics.md"        .claude/commands/metrics.md
  print_substep "/project:plan, /implement, /handoff, /review, /freshstart, /compact-save, /security-audit, /metrics"

  if [ "$METHOD_LEVEL" -ge 2 ]; then
    cp "${tpl}/standard/adr-command.md" .claude/commands/adr.md
    print_substep "/project:adr — создание Architecture Decision Record"
  fi

  # ── Sub-agents (Standard+) ──
  if [ "$METHOD_LEVEL" -ge 2 ]; then
    print_step "Устанавливаю sub-agents..."
    cp "${tpl}/agents/frontend-ux.md"        .claude/agents/frontend-ux.md
    cp "${tpl}/agents/test-writer.md"        .claude/agents/test-writer.md
    cp "${tpl}/agents/security-reviewer.md"  .claude/agents/security-reviewer.md
    cp "${tpl}/agents/db-migration.md"       .claude/agents/db-migration.md
    print_substep "frontend-ux, test-writer, security-reviewer, db-migration"

    # Stack-specific agents
    if [[ "$STACK_PRESET" == "tauri-sveltekit" ]]; then
      cp "${tpl}/agents/rust-tauri.md" .claude/agents/rust-tauri.md
      print_substep "rust-tauri (для Tauri-стека)"
    fi
    if [[ "$STACK_PRESET" == "tauri-sveltekit" || "$STACK_PRESET" == "expo-rn" ]]; then
      cp "${tpl}/agents/sync-engineer.md" .claude/agents/sync-engineer.md
      cp "${tpl}/agents/a11y-reviewer.md" .claude/agents/a11y-reviewer.md
      print_substep "sync-engineer, a11y-reviewer (для cross-platform)"
    fi
  fi

  # ── Modular rules ──
  print_step "Создаю модульные правила..."
  cp "${tpl}/rules/security.md" .claude/rules/security.md
  cp "${tpl}/rules/git.md"      .claude/rules/git.md
  print_substep "security.md, git.md"

  # Path-scoped testing rules (split for App/Standard+, single for Minimal)
  if [ "$METHOD_LEVEL" -ge 2 ]; then
    cp "${tpl}/rules/testing-server.md"      .claude/rules/testing-server.md
    cp "${tpl}/rules/testing-ui.md"          .claude/rules/testing-ui.md
    cp "${tpl}/rules/testing-integration.md" .claude/rules/testing-integration.md
    print_substep "testing-server.md, testing-ui.md, testing-integration.md (path-scoped)"
  else
    cp "${tpl}/rules/testing.md" .claude/rules/testing.md
    print_substep "testing.md (single rules file for Minimal tier)"
  fi

  # ── Memory Bank (Standard+) ──
  if [ "$METHOD_LEVEL" -ge 2 ]; then
    print_step "Инициализирую Memory Bank..."
    local mb="${tpl}/standard/memory-bank"
    generate_from_template "${mb}/projectbrief.md.tpl"   memory-bank/projectbrief.md
    generate_from_template "${mb}/productContext.md.tpl" memory-bank/productContext.md
    generate_from_template "${mb}/systemPatterns.md.tpl" memory-bank/systemPatterns.md
    generate_from_template "${mb}/techContext.md.tpl"    memory-bank/techContext.md
    generate_from_template "${mb}/activeContext.md.tpl"  memory-bank/activeContext.md
    generate_from_template "${mb}/progress.md.tpl"       memory-bank/progress.md
    print_substep "6 файлов Memory Bank"
  fi

  # ── MCP bootstrap (Standard+) ──
  if [ "$METHOD_LEVEL" -ge 2 ]; then
    print_step "Создаю MCP-конфигурацию..."
    generate_from_template "${tpl}/base/mcp.json.tpl" .mcp.json
    generate_from_template "${tpl}/base/mcp.README.md" docs/MCP.md
    print_substep ".mcp.json (все серверы выключены: префикс \$_) + docs/MCP.md"
  fi

  # ── Planning files ──
  print_step "Создаю файлы планирования..."
  generate_from_template "${tpl}/base/PRD.md.tpl"      PRD.md
  generate_from_template "${tpl}/base/PLANNING.md.tpl" PLANNING.md
  cp "${tpl}/base/TASKS.md.tpl" TASKS.md
  print_substep "PRD.md, PLANNING.md, TASKS.md"

  # ── Documentation ──
  print_step "Создаю шаблоны документации..."
  cp "${tpl}/docs/ARCHITECTURE.md" docs/ARCHITECTURE.md
  print_substep "docs/ARCHITECTURE.md"
  if [ "$METHOD_LEVEL" -ge 2 ]; then
    cp "${tpl}/standard/adr-template.md" adr/000-template.md
    print_substep "adr/000-template.md"
  fi

  # ── Quality Gates: Full + App ──
  if [ "$METHOD_LEVEL" -ge 3 ]; then
    print_step "Создаю Quality Gates..."
    cp "${tpl}/full/architecture-gate.md" .claude/quality-gates/architecture-gate.md
    print_substep "architecture-gate.md"

    if [ "$METHOD_LEVEL" -eq 3 ]; then
      cp "${tpl}/full/gate-check-command.md" .claude/commands/gate-check.md
      print_substep "/project:gate-check — Full tier"
    fi
  fi

  if [ "$METHOD_LEVEL" -ge 4 ]; then
    cp "${tpl}/app/offline-first-gate.md"   .claude/quality-gates/offline-first-gate.md
    cp "${tpl}/app/cross-platform-gate.md"  .claude/quality-gates/cross-platform-gate.md
    cp "${tpl}/app/a11y-gate.md"            .claude/quality-gates/a11y-gate.md
    cp "${tpl}/app/performance-gate.md"     .claude/quality-gates/performance-gate.md
    cp "${tpl}/app/privacy-gate.md"         .claude/quality-gates/privacy-gate.md
    cp "${tpl}/app/app-tier-overview.md"    .claude/quality-gates/README.md
    cp "${tpl}/app/gate-check-app-command.md" .claude/commands/gate-check.md
    print_substep "offline-first, cross-platform, a11y, performance, privacy gates"
    print_substep "/project:gate-check (App-tier extended)"

    # a11y agent always present at App tier
    if [ ! -f .claude/agents/a11y-reviewer.md ]; then
      cp "${tpl}/agents/a11y-reviewer.md" .claude/agents/a11y-reviewer.md
      print_substep "a11y-reviewer agent (App tier default)"
    fi
  fi

  # ── .gitignore ──
  print_step "Генерирую .gitignore..."
  cp "${tpl}/base/gitignore.tpl" .gitignore
  print_substep ".gitignore создан"

  # ── INIT_PROMPT.md ──
  print_step "Генерирую мастер-промпт для первого запуска Claude Code..."
  cp "${tpl}/base/INIT_PROMPT.md.tpl" INIT_PROMPT.md
  print_substep "INIT_PROMPT.md"

  # ── Monorepo skeleton ──
  if [ "${MONOREPO:-0}" -eq 1 ]; then
    print_step "Раскладываю monorepo-каркас..."
    generate_monorepo_skeleton
    print_substep "package.json (root), pnpm-workspace.yaml, apps/*, packages/*"
  fi
}

# ── Monorepo skeleton ────────────────────────────────────────────────────────

generate_monorepo_skeleton() {
  cat > pnpm-workspace.yaml << 'EOF'
packages:
  - "apps/*"
  - "packages/*"
EOF

  cat > package.json << EOF
{
  "name": "${PROJECT_NAME}",
  "private": true,
  "version": "0.0.0",
  "description": "${PROJECT_DESC}",
  "packageManager": "pnpm@9.0.0",
  "scripts": {
    "dev": "pnpm -r --parallel dev",
    "build": "pnpm -r build",
    "test": "pnpm -r test",
    "lint": "pnpm -r lint",
    "typecheck": "pnpm -r typecheck"
  },
  "engines": {
    "node": ">=20.0.0",
    "pnpm": ">=9.0.0"
  }
}
EOF

  for pkg in apps/web apps/desktop apps/mobile packages/core packages/db packages/ui packages/config packages/sync; do
    [ -d "$pkg" ] || continue
    local pkg_name
    pkg_name="@${PROJECT_NAME}/$(basename "$pkg")"
    cat > "$pkg/package.json" << EOF
{
  "name": "${pkg_name}",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "echo 'TODO: dev command for ${pkg}'",
    "build": "echo 'TODO: build command for ${pkg}'",
    "test": "echo 'TODO: test command for ${pkg}'",
    "lint": "echo 'TODO: lint command for ${pkg}'",
    "typecheck": "echo 'TODO: typecheck command for ${pkg}'"
  }
}
EOF
    echo "# ${pkg_name}" > "$pkg/README.md"
  done
}

# ── settings.json ────────────────────────────────────────────────────────────

generate_settings_json() {
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

  print_substep "Permissions (deny: .env, .pem, .key, secrets)"
  print_substep "PostToolUse: auto-format + auto-lint"
  print_substep "PreToolUse: блокировка деструктивных команд"
  print_substep "Stop: автозапуск тестов"
}

# ── Git initialization ───────────────────────────────────────────────────────

init_git() {
  if [ -d .git ]; then
    print_step "Git уже инициализирован — пропускаю init"
    return
  fi
  print_step "Инициализирую Git..."
  git init -q
  git add -A
  git commit -q -m "chore: bootstrap project with Claude Code methodology (level ${METHOD_LEVEL})" 2>/dev/null || \
    print_warning "Git commit пропущен (настройте git config user.name / user.email)"
  print_substep "Первый коммит создан"
}

# ── Summary output ───────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║${NC}  ${GREEN}${BOLD}ПРОЕКТ УСПЕШНО СОЗДАН!${NC}                                     ${CYAN}║${NC}"
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${BOLD}Структура проекта:${NC}"
  echo ""

  if command -v tree &> /dev/null; then
    tree -a -I '.git|node_modules' --dirsfirst -L 3
  else
    find . -not -path './.git/*' -not -path './.git' | head -80 | sort
  fi

  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}Следующие шаги:${NC}"
  echo ""
  echo -e "  ${CYAN}1.${NC} Открой проект в VSCode:"
  if [ "${IN_PLACE:-0}" -eq 1 ]; then
    echo -e "     ${DIM}code .${NC}"
  else
    echo -e "     ${DIM}code ${PROJECT_NAME}${NC}"
  fi
  echo ""
  echo -e "  ${CYAN}2.${NC} Запусти Claude Code и:"
  echo -e "     ${DIM}/project:freshstart${NC}"
  echo ""
  echo -e "  ${CYAN}3.${NC} Доступные команды:"
  echo -e "     ${DIM}/project:plan [задача]${NC}      — спланировать"
  echo -e "     ${DIM}/project:implement [задача]${NC} — реализовать (TDD)"
  echo -e "     ${DIM}/project:handoff${NC}            — передать контекст"
  echo -e "     ${DIM}/project:review${NC}             — code review"
  echo -e "     ${DIM}/project:metrics${NC}            — отчёт по сессии"
  echo -e "     ${DIM}/project:compact-save${NC}       — безопасная компакция"
  echo -e "     ${DIM}/project:security-audit${NC}     — аудит безопасности"
  if [ "$METHOD_LEVEL" -ge 2 ]; then
    echo -e "     ${DIM}/project:adr [тема]${NC}         — создать ADR"
  fi
  if [ "$METHOD_LEVEL" -ge 3 ]; then
    echo -e "     ${DIM}/project:gate-check${NC}         — Quality Gates"
  fi
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${DIM}Methodology: Structured Development with Claude Code v2.1${NC}"
  echo -e "${DIM}Tier: ${METHOD_LEVEL} (1=Minimal, 2=Standard, 3=Full, 4=App)${NC}"
  echo -e "${DIM}Monorepo: $([ "${MONOREPO:-0}" -eq 1 ] && echo "yes" || echo "no")${NC}"
  echo ""
}
