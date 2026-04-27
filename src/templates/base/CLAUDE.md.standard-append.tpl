
## Memory Bank
- @memory-bank/ — персистентная память проекта (читать в начале каждой задачи)

## Architecture Decision Records
- See /adr/ for detailed decisions (заполняется по мере принятия решений)

## Memory delegation (Memory Bank ↔ auto-memory)
Эти два механизма памяти **не дублируют, а дополняют** друг друга:

- **Memory Bank** (`memory-bank/*.md`) — широкие, проектные знания: архитектура, домен, паттерны.
  Читается на старте сессии (`/project:freshstart`), редактируется явно, версионируется в git.
- **Auto-memory** (`~/.claude/projects/*/MEMORY.md`) — узкие, агентские знания: предпочтения пользователя,
  обратная связь по стилю, временные ссылки на внешние ресурсы. Управляется автоматически, не в git.

**Правило выбора:**
- Факт о *проекте* → Memory Bank
- Факт о *том, как с пользователем работать* (тон, формат, привычки) → auto-memory
- Конкретная сегодняшняя задача → не сохранять, использовать TodoWrite

## Sub-agents
- `.claude/agents/` — специализированные роли (frontend-ux, db-migration, security-reviewer и др.)
  Запускаются автоматически Claude Code, когда задача матчится по описанию агента.

## MCP servers
- `.mcp.json` — внешние интеграции (filesystem / github / postgres / playwright / figma).
  По умолчанию все отключены (`$_` префикс) — включай по мере необходимости.
