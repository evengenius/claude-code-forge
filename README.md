<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-v2.1+_(2026)-6C47FF?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/Skills_%2B_Subagents-active-22c55e?style=for-the-badge" alt="Skills">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=for-the-badge" alt="PRs Welcome">
</p>

<h1 align="center">🔨 Claude Code Forge</h1>

<p align="center">
  <strong>Структурированная методология разработки с Claude Code</strong><br>
  <em>От хаоса вайб-кодинга к управляемому инженерному процессу</em>
</p>

<p align="center">
  <a href="#быстрый-старт">Быстрый старт</a> •
  <a href="#зачем-это-нужно">Зачем</a> •
  <a href="#что-создаёт-скрипт">Что создаёт</a> •
  <a href="#методология">Методология</a> •
  <a href="#справочник-команд">Команды</a> •
  <a href="#faq">FAQ</a>
</p>

---

## Зачем это нужно

Вайб-кодинг с Claude Code работает — пока проект маленький. На 500 строках можно обходиться без структуры. Но стоит проекту вырасти, и начинаются знакомые проблемы:

| Проблема | Причина | Как решает Forge |
|----------|---------|------------------|
| Claude «забывает» решения из начала сессии | Переполнение контекстного окна | Memory Bank + handoff-документы + `/compact` стратегия |
| Одна правка ломает другую часть | Нет тестовой дисциплины | Принудительный TDD через команды + Stop-хук с автозапуском тестов |
| Claude игнорирует стилевые правила | Инструкции CLAUDE.md — «мягкие» | Детерминистические хуки: auto-format + auto-lint при каждом сохранении |
| Токены сгорают на повторных объяснениях | Нет персистентной памяти | 6 файлов Memory Bank + ADR — контекст загружается автоматически |
| Секреты попадают в контекст | Нет защиты чувствительных файлов | `permissions.deny` + `.claudeignore` + хук блокировки опасных команд (требует `jq`) |
| Проект разваливается при возврате через неделю | Контекст хранится «в голове» | Handoff-документы + memory bank + именованные сессии |
| Claude делает всё сразу и плохо | Задачи слишком крупные | Декомпозиция на «intern-sized» задачи (1–4 часа) с зависимостями |

**Claude Code Forge** — это bootstrap-скрипт + методология, которые за одну команду создают полную инфраструктуру для структурированной разработки любой сложности.

Версия v3.0 (май 2026) приведена в соответствие с актуальной экосистемой Claude Code:
- **Skills** (`.claude/skills/<name>/SKILL.md` с frontmatter) вместо deprecated commands
- **Subagents** (`.claude/agents/`) — code-reviewer, security-reviewer, test-writer
- **Path-scoped rules** (YAML `paths:` frontmatter) — авто-загрузка по контексту
- **@-imports** в CLAUDE.md (включая `@AGENTS.md` для совместимости)
- **GitHub Actions** для headless Claude review (`claude --bare -p`)
- **Pre-commit + gitleaks** — defence-in-depth против slopsquatting и AI-leaked secrets
- **ADR-0001** записывает стандарты AI-разработки на старте проекта

---

## Быстрый старт

### Требования

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (установлен и авторизован)
- VSCode с расширением Claude Code
- Подписка Pro / Max / Team / Enterprise
- bash (Linux, macOS, WSL)
- git ≥ 2.28 (для `git init -b main`; на старых версиях используется фолбэк)
- python3 (для безопасной генерации `settings.json` без проблем с экранированием)
- jq (для работы хуков auto-format / блокировки опасных команд — `apt install jq` или `brew install jq`)

### Установка и запуск

```bash
# Скачать скрипт
curl -fsSL https://raw.githubusercontent.com/Evengenius/claude-code-forge/main/init-claude-project.sh -o init-claude-project.sh

# Рекомендуется: проинспектировать содержимое перед запуском
less init-claude-project.sh

chmod +x init-claude-project.sh

# Создать проект
./init-claude-project.sh my-project
```

> **Безопасность**: скрипт скачивается напрямую с GitHub без подписи. Прежде чем запускать (`./init-claude-project.sh`), просмотрите код — это стандартная практика для произвольных установочных скриптов из интернета.

Скрипт задаст три вопроса:

1. **Описание проекта** — 1–2 предложения о сути продукта
2. **Тех-стек** — выбор из 5 пресетов или ввод вручную:
   - `1` Next.js + TypeScript + Prisma + PostgreSQL
   - `2` React + TypeScript + Vite
   - `3` Node.js + Express + TypeScript
   - `4` Python + FastAPI + SQLAlchemy
   - `5` Кастомный стек
3. **Уровень методологии**:
   - `1` **Minimal** — для MVP и соло-проектов
   - `2` **Standard** — для средних проектов (рекомендуется)
   - `3` **Full** — для крупных проектов с quality gates

Затем откройте проект и запустите Claude Code:

```bash
code my-project
# В Claude Code вставьте содержимое INIT_PROMPT.md
# или выполните: /freshstart
```

---

## Что создаёт скрипт

### Уровень 1 — Minimal

```
my-project/
├── CLAUDE.md                                   # Главный файл (≤120 строк, @-imports)
├── CLAUDE.local.md                             # Личные настройки (gitignored)
├── INIT_PROMPT.md                              # Мастер-промпт для первой сессии
├── .claudeignore                               # Исключения из контекста Claude
├── .gitignore                                  # + .claude/settings.local.json, .env*, secrets/
├── .pre-commit-config.yaml                     # gitleaks + lint + conventional commits
│
├── .claude/
│   ├── settings.json                           # permissions (allow/deny/ask) + hooks
│   ├── settings.local.json                     # Личный шаблон (gitignored)
│   │
│   ├── skills/                                 # Новый формат (заменяет commands)
│   │   ├── freshstart/SKILL.md                 #   /freshstart — старт сессии
│   │   ├── plan/SKILL.md                       #   /plan — Plan Mode с TDD
│   │   ├── implement/SKILL.md                  #   /implement — RED→GREEN→REFACTOR
│   │   ├── code-review/SKILL.md                #   /code-review — self-review
│   │   ├── handoff/SKILL.md                    #   /handoff (disable-model-invocation)
│   │   ├── compact-save/SKILL.md               #   /compact-save (на 60%, не 80%)
│   │   ├── security-audit/SKILL.md             #   /security-audit (context: fork)
│   │   └── commit/SKILL.md                     #   /commit — conventional commits
│   │
│   ├── agents/                                 # Subagents — изолированный контекст
│   │   ├── code-reviewer.md                    #   opus, для PR review
│   │   ├── security-reviewer.md                #   opus, OWASP + supply chain
│   │   └── test-writer.md                      #   sonnet, TDD-first
│   │
│   └── rules/                                  # Path-scoped правила (auto-loaded)
│       ├── security.md                         #   Глобальное (всегда)
│       ├── git.md                              #   Глобальное (всегда)
│       ├── code-quality.md                     #   YAGNI, anti-overengineering
│       └── testing.md                          #   paths: **/*.test.*, tests/**
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yml                              # Lint + test + gitleaks
│   │   └── claude-review.yml                   # Auto PR review через claude --bare -p
│   └── pull_request_template.md                # AI-code review checklist
│
├── PRD.md                                      # Product Requirements Document
├── PLANNING.md                                 # Архитектура и процесс
├── TASKS.md                                    # Задачи с зависимостями
├── docs/ARCHITECTURE.md                        # Архитектурный обзор
└── src/                                        # Исходный код
```

### Уровень 2 — Standard (добавляет к Minimal)

```
├── memory-bank/                                # Персистентная память между сессиями
│   ├── projectbrief.md                         #   Цели, scope, ограничения
│   ├── productContext.md                       #   Продуктовые требования, UX
│   ├── systemPatterns.md                       #   Архитектурные паттерны
│   ├── techContext.md                          #   Стек, зависимости, окружение
│   ├── activeContext.md                        #   Текущий фокус работы
│   └── progress.md                             #   Прогресс и known issues
│
├── adr/                                        # Architecture Decision Records
│   ├── _template.md                            #   Шаблон ADR (нумерация с 001)
│   └── 0001-ai-assisted-development.md         #   Стандарты AI-разработки
│
├── _todo/                                      # Handoff-документы
├── _done/                                      # Завершённые handoff (gitignored)
│
└── .claude/skills/adr/SKILL.md                 # /adr <тема> — создать ADR
```

### Уровень 3 — Full (добавляет к Standard)

```
├── .claude/
│   ├── quality-gates/architecture-gate.md      # Чек-лист на 10 пунктов (≥90/100)
│   └── skills/gate-check/SKILL.md              # /gate-check — Quality Gate
│
├── .devcontainer/devcontainer.json             # Sandbox для autonomous Claude runs
└── specs/                                      # Спецификации
```

---

## Методология

### Ключевые принципы (Anthropic Best Practices 2026)

```
┌──────────────────────────────────────────────────────────────────┐
│                                                                  │
│   ВАЙБ-КОДИНГ            →   FORGE v3.0 (2026)                   │
│                                                                  │
│   «Сделай мне фичу»      →   Explore → Plan → Implement →        │
│                              Verify → Commit                     │
│   Надежда на CLAUDE.md   →   Детерминистические хуки + Skills    │
│   Контекст в голове      →   Memory Bank + Handoff + Subagents   │
│   Тесты потом            →   TDD: RED → GREEN → REFACTOR         │
│   Тесты как покрытие     →   Verification как #1 leverage        │
│   Одна гигантская сессия →   Задачи 1-4 часа, /clear между       │
│   Auto-compact на 83%    →   Manual /compact на 60%              │
│   Trust the AI           →   AI-code PR checklist, gitleaks      │
│   Любые зависимости      →   Проверка против slopsquatting       │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Что подтверждено эмпирически

- **METR RCT 2025**: опытные разработчики на знакомой кодобазе с AI — **-19%** скорости.
  На greenfield/boilerplate — **+200-500%**. Sweet spot: задачи на 1 фичу / 3-5 файлов / 200-400 LOC.
- **Shiplight 2025**: AI-код имеет **1.7× больше багов** на единицу кода.
- **DORA 2025**: AI — амплификатор. Хорошие процессы → ещё лучше. Плохие → катастрофа.
- **Trend Micro / Andrew Nesbitt 2025**: **19.7%** LLM-предложенных npm/pip пакетов галлюцинированы
  (slopsquatting). Минимум 23 атаки в production за 2025-2026.

### Иерархия CLAUDE.md

Claude Code поддерживает 4 уровня конфигурации (загружаются снизу вверх, все конкатенируются):

| Приоритет | Файл | Назначение |
|-----------|------|-----------|
| 1 (высший) | `CLAUDE.local.md` | Личные настройки проекта (в .gitignore) |
| 2 | `CLAUDE.md` | Командные правила проекта (в git) |
| 3 | `~/.claude/CLAUDE.md` | Глобальные личные предпочтения |
| 4 (низший) | Managed Policy | Корпоративные правила (если применимо) |

**Бюджет инструкций**: по [эмпирическим наблюдениям сообщества](https://www.humanlayer.dev/blog/writing-a-good-claude-md) Claude стабильно держит ~150–200 инструкций суммарно, из которых часть уже занята системным промптом. Эта цифра не документирована Anthropic — относитесь к ней как к ориентиру. Forge держит CLAUDE.md в пределах 40–60 строк, вынося детали в `.claude/rules/` (подгружаются явной ссылкой из CLAUDE.md, не автоматически) и хуки (детерминистические, выполняются хостом, не тратят бюджет инструкций).

### Система хуков

Хуки — реальный код, который выполняется хостом и невозможно обойти, в отличие от инструкций CLAUDE.md. Claude Code 2026 поддерживает [28+ event-типов](https://code.claude.com/docs/en/hooks); Forge настраивает критичные:

**PostToolUse** (matcher: `Edit|Write`) — auto-format + auto-lint после правок. Данные через stdin как JSON, парсятся `jq`.

**PreToolUse** (matcher: `Bash`) — блокировка деструктивных команд по regex. Покрывает: `rm -rf /`, `rm -rf ~`, `git push --force main/master/prod`, `git reset --hard`, `curl ... | sh`, `chmod 777`, `DROP TABLE`, `mkfs.*`, `dd if=...of=/dev/sd*`. Exit 2 → блок + информативное сообщение в Claude.

**PreToolUse** (matcher: `Write|Edit`) — отказ от записи в `.env*`, `*.key`, `*.pem`, `credentials/`, `secrets/`, `.ssh/`. Защищает от случайного оверрайда секретов.

**Зависимость**: хуки парсят stdin через `jq` (`apt install jq` / `brew install jq`). Без `jq` хуки no-op — скрипт это проверяет.

**Другие полезные events** (включайте по необходимости):
- `SessionStart` — установка зависимостей в cloud-окружении
- `PreCompact` — сохранение important state перед auto-compaction
- `InstructionsLoaded` — debug загрузки CLAUDE.md и path-scoped rules
- `UserPromptSubmit` — модификация/обогащение пользовательских промптов

### Permissions: allow / deny / ask

Forge настраивает все три уровня. Эволюция от прошлой версии:

- **Не дублируем read-only** (`ls`, `cat`, `head`, `tail`, `grep`, `find`, `wc`, `git log/diff/status`) — Claude Code знает их встроенно как read-only, добавлять в allow бесполезно.
- **`ask` для опасных, но не запрещённых**: `git push`, `gh pr merge`, `gh release`, `kubectl`, `docker push`, `npm publish`, `rm -rf *` — требуют одобрения, но возможны.
- **`deny` строгий**: секреты, force-push в main/master/prod, hard reset, curl|sh, sudo, запись в `/etc /usr /var /.git`.
- **`WebFetch(domain:...)`** для предсказуемого сетевого доступа: разрешены `docs.anthropic.com`, `code.claude.com`, `github.com`, `developer.mozilla.org`. Bash `curl`/`wget` запрещены (через WebFetch предсказуемо, через bash — атаковый вектор).

### Управление контекстом

Контекстное окно — **главный ограниченный ресурс**. LLM-perf деградирует **непрерывно** с заполнением, не на скачке (Anthropic Best Practices, см. также arXiv:2511.* про context decay).

**Превентивный** — не допускать переполнения:
- `.claudeignore` исключает node_modules, билды, логи, данные
- `permissions.deny` блокирует чтение секретов и больших файлов
- Задачи размером 1–4 часа (METR sweet spot: 200-400 LOC / 3-5 файлов)
- `/clear` между несвязанными задачами

**Оперативный** — при заполнении **60%** (не ждать 83% auto-compact):
- `/compact-save` — сохранить важное в memory-bank перед компакцией
- `/compact <инструкция>` — сжатие с явным указанием что сохранить
- Subagents для исследования (изолированный контекст, возвращают summary)

**Межсессионный** — сохранение контекста между сессиями:
- Memory Bank — загружается явно через `@`-imports в CLAUDE.md
- Auto memory Claude Code (`~/.claude/projects/<repo>/memory/`) — Claude сам ведёт
- Handoff-документы в `_todo/` — структурированная передача
- ADR — архитектурные решения, не пересматриваются заново
- Checkpoints (`/rewind` или Esc Esc) — откат к предыдущей точке

### TDD-цикл

Forge навязывает Test-Driven Development через skill `/implement` и path-scoped правила `.claude/rules/testing.md` (автоматически грузятся когда Claude правит файл по pattern `**/*.test.*`):

```
RED:      Напиши ОДИН падающий тест. Запусти — убедись что падает осмысленно.
GREEN:    Напиши МИНИМАЛЬНЫЙ код для прохождения. Запусти — проходит.
REFACTOR: Улучши код, проверяя тесты после каждого шага.
REPEAT.
```

**Verification — #1 leverage** (Anthropic): помимо тестов, давай Claude способ верифицировать визуально — скриншоты, expected output, `claude --bare -p "compare these"`. Без verification Claude производит plausible-looking но broken код.

### Architecture Decision Records (ADR)

Каждое нетривиальное архитектурное решение записывается в отдельный файл `adr/NNN-slug.md` со структурой: Context → Decision → Alternatives Considered → Consequences.

Это решает проблему «почему мы выбрали X?» — Claude читает ADR вместо повторного обсуждения. Команда `/adr` автоматизирует создание.

### Quality Gates (уровень Full)

Перед переходом от планирования к реализации `/gate-check` проверяет 10 обязательных пунктов:

- PRD заполнен полностью
- Архитектура задокументирована
- Data model определена
- API design задокументирован
- Тестовая стратегия описана
- Задачи декомпозированы с зависимостями
- ADR созданы для нетривиальных решений
- ...и ещё 3 пункта

**Проходной балл: 90/100.** Если не набран — Claude перечисляет что доработать.

---

## Справочник команд

### Skills Forge (.claude/skills/)

| Skill | Описание | Когда использовать |
|-------|----------|-------------------|
| `/freshstart` | Загрузить контекст проекта (CLAUDE.md, memory-bank, TASKS, git, handoff), доложить статус | Старт каждой сессии |
| `/plan <задача>` | Plan Mode: разбор задачи на TDD-первый план с тестами и рисками | Перед задачей >30 мин или незнакомой |
| `/implement <задача>` | TDD RED → GREEN → REFACTOR (с явным запретом изменять тесты под код) | После принятия плана |
| `/code-review [scope]` | Self-review с классификацией 🔴🟡🔵 + AI-specific checklist (over-abstraction, phantom deps) | Перед коммитом/PR |
| `/handoff` | Создать `_todo/handoff-YYYY-MM-DD.md` + обновить memory-bank | Конец сессии |
| `/compact-save` | Сохранить активный контекст в memory-bank ПЕРЕД /compact | На 60% контекста (не 80%!) |
| `/security-audit [scope]` | OWASP + supply chain в forked Explore-агенте (не засоряет main context) | Перед релизом, периодически |
| `/commit` | Conventional commit с подтверждением diff | Когда готов фиксировать |
| `/adr <тема>` *(Standard+)* | Создать Architecture Decision Record | При нетривиальном решении |
| `/gate-check` *(Full)* | Quality Gate (10 пунктов, ≥90/100) | Перед переходом план→реализация |

### Subagents Forge (.claude/agents/)

Claude автоматически делегирует подходящие задачи. Можно явно: «Use the code-reviewer subagent to review this PR».

| Subagent | Модель | Назначение |
|----------|--------|-----------|
| `code-reviewer` | opus | PR-review, AI-antipatterns, изолированный контекст |
| `security-reviewer` | opus | OWASP Top 10 + slopsquatting + supply chain |
| `test-writer` | sonnet | TDD-first генерация тестов под существующий код |

### Встроенные команды Claude Code

| Команда | Описание |
|---------|----------|
| `/init` | Анализировать репо и сгенерировать/обновить CLAUDE.md (с `CLAUDE_CODE_NEW_INIT=1` — интерактивный multi-phase flow) |
| `/review` | Built-in review (не путать с нашим `/code-review`) |
| `/security-review` | Built-in security review |
| `/run`, `/verify` | Built-in skills для запуска и верификации app (Claude Code v2.1.145+) |
| `/compact [инструкция]` | Сжать историю, сохранив указанный контекст |
| `/clear` | Полная очистка истории сессии |
| `/context` | Показать распределение токенов |
| `/cost` | Показать расход токенов за сессию |
| `/model sonnet\|opus\|haiku` | Переключить модель |
| `/permissions` | Управление permissions |
| `/agents` | Управление subagents |
| `/memory` | Просмотр/редактирование CLAUDE.md + auto memory |
| `/rewind` (или Esc Esc) | Checkpoint: откат к предыдущей точке conversation/code |
| `Shift+Tab` | Циклический переключатель режимов (default → acceptEdits → plan) |

### Рекомендуемый ежедневный workflow (Anthropic Best Practices)

```
Старт сессии:
  /freshstart                     ← загрузить контекст, увидеть статус
  Выбрать задачу из TASKS.md
  Shift+Tab → Plan Mode
  /plan <задача>                  ← Explore + структурированный план

Реализация:
  Shift+Tab → default mode
  /implement <задача>             ← TDD RED → GREEN → REFACTOR
  (verification — запуск тестов, screenshots — обязательно)

Управление контекстом:
  /clear                          ← между несвязанными задачами
  /compact-save && /compact "..." ← при 60% (не 80%!)
  Use subagent for research       ← grep по всему репо — в subagent

Завершение:
  /code-review                    ← self-review (BLOCKER/WARNING/SUGGESTION)
  /commit                         ← conventional commit
  /handoff                        ← сохранить контекст
```

### Headless mode (CI/CD)

```bash
# Воспроизводимый запуск без локальных hooks/skills/MCP
claude --bare -p "Review this diff for security issues" \
  --output-format json --allowedTools "Read"

# В GitHub Actions — см. .github/workflows/claude-review.yml
# Стоимость: ~$0.05-0.20 на PR (зависит от размера и модели)
```

---

## Безопасность AI-разработки (2025-2026)

За 2025-2026 произошло несколько реальных инцидентов, которые повлияли на дизайн методологии:

| Инцидент | Дата | Что произошло | Меры в Forge |
|----------|------|---------------|--------------|
| CVE-2025-54794/54795/59536 | 2025 | Path & command injection в Claude Code wrappers | PreToolUse hook с расширенным regex |
| Claude Code source leak — bypass deny-rule | 2026-03 | Cap в 50 subcommands давал обход | Узкий allow + deny на всех уровнях, не только Bash |
| PromptMink npm malware via Claude commit | 2026-02 | AI-сгенерированный коммит с malware-пакетом | Pre-commit gitleaks + lockfile-only + `--ignore-scripts` |
| Shai Hulud / SAP CAP supply-chain | 2026-04 | Атака через AI-suggested зависимость | ADR-0001 + AI-code PR checklist (проверка new deps) |
| MCP Supply Chain Advisory | 2025-2026 | RCE через скомпрометированные MCP-серверы | `.mcp.json` только из доверенных источников; `--bare` в CI |

**Slopsquatting** — отдельный класс: 19.7% LLM-предложенных пакетов галлюцинированы. Атакующие регистрируют эти имена с malware. Защита:
1. Лoackfile-only установка (`npm ci`, `pip-compile`)
2. Проверка нового пакета на [deps.dev](https://deps.dev) / [ecosys.dev](https://ecosys.dev) перед добавлением
3. `npm install --ignore-scripts` для AI-driven
4. AI-code PR checklist обязывает указать обоснование каждой новой зависимости

**Prompt injection** через issues, PR descriptions, fetched URLs, MCP outputs — **>85% success rate** в adaptive attacks (Jan 2026 meta-analysis 78 исследований). Меры:
- Никогда не запускать Claude Code на untrusted репозитории без sandbox (`.devcontainer/`)
- MCP-серверы — только проверенные, не подключать «interesting» серверы случайных авторов
- Бесконтрольный autonomous mode (`--permission-mode bypassPermissions`) **только** внутри контейнера

---

## Антипаттерны (что НЕ работает)

Подтверждено эмпирически — эти подходы дают худший результат чем без AI:

| Антипаттерн | Симптом | Фикс |
|-------------|---------|------|
| **Kitchen sink session** | «Одна задача → ещё вопрос → ещё → задача» — контекст полон мусора | `/clear` между несвязанными задачами |
| **Correcting over and over** | Claude делает не то → коррекция → опять не то → опять коррекция | После 2 неудачных коррекций — `/clear` + переформулировка |
| **Over-specified CLAUDE.md** | CLAUDE.md >200 строк — Claude игнорирует половину | Безжалостно режь. Если правило не повлияло — удали или замени хуком |
| **Trust-then-verify gap** | Plausible-looking код, который не работает | Verify всегда: тесты, скриншоты, expected output |
| **Infinite exploration** | «Исследуй X» без scope → Claude читает 100 файлов | Узкий scope или subagent (изолированный контекст) |
| **One mega-prompt** | «Сделай всю фичу за раз» → over-abstracted enterprise patterns | Plan Mode → разбить на 1-4-часовые задачи |
| **Reflexive abstraction** | AI любит Factory/Repository/Strategy на CRUD | `code-quality.md` правило: YAGNI, prefer functions |
| **Phantom packages** | AI ссылается на несуществующий пакет → install → slopsquatting | Pre-commit gitleaks + проверка deps.dev перед добавлением |
| **Дроп defensive logic** | Рефакторинг «убрал» null checks/rate limits/idempotency | `code-quality.md`: оставлять защитную логику до объяснения |
| **Rubber-stamp review** | «AI сделал, я просто посмотрел» — 1.7× больше багов | AI-code PR checklist обязателен |

---

## Совместимость с фреймворками

Forge создаёт базовую инфраструктуру, совместимую с продвинутыми фреймворками:

| Фреймворк | Что делает | Как совмещать с Forge |
|-----------|-----------|----------------------|
| **[BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD)** | Полный agile с AI-агентами (12+ ролей) | Forge → базовая структура; BMAD → фазы планирования и качественные ворота |
| **[Taskmaster-AI](https://github.com/eyaltoledano/claude-task-master)** | Управление задачами через MCP | Forge → TASKS.md как отправная точка; Taskmaster → автоматический граф зависимостей |
| **[Memory Bank (Cline)](https://github.com/cline/prompts)** | Персистентная память | Forge уже включает адаптированный Memory Bank |

---

## Настройка под свой стек

### Добавить свои хуки

Отредактируйте `.claude/settings.json`, секция `hooks`. Claude Code передаёт данные хуку через **stdin как JSON** (`{tool_input: {file_path: ...}}`); парсить нужно через `jq`:

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "f=\"$(jq -r '.tool_input.file_path // empty')\"; [ -n \"$f\" ] && your-formatter \"$f\" || true"
          }
        ]
      }
    ]
  }
}
```

> Для работы хуков нужен установленный `jq` (`apt install jq` или `brew install jq`).

### Добавить свои правила

Создайте файл в `.claude/rules/` и добавьте на него ссылку в `CLAUDE.md` — Claude Code не загружает правила автоматически по пути, поэтому управляем явно:

```markdown
<!-- .claude/rules/api-validation.md -->
# API validation rules
- Все API-эндпоинты валидируют вход через zod-схему
- Возвращают 400 при невалидных данных с описанием ошибки
```

В CLAUDE.md:
```markdown
## Project Rules
- При работе с `src/api/**` читай `.claude/rules/api-validation.md`
```

### Добавить свои команды

Создайте файл в `.claude/commands/`:

```markdown
<!-- .claude/commands/deploy.md -->
Выполни деплой. Процесс:
1. Запусти тесты
2. Собери проект
3. Покажи diff с последнего деплоя
4. Спроси подтверждение
Параметры: $ARGUMENTS
```

Вызов: `/deploy staging`

---

## Экономия токенов

### Выбор модели — максимальный рычаг

```bash
/model sonnet          # 80% задач — дешевле и быстрее
/model opus            # Сложная архитектура и отладка
# Или: alias opusplan  # Opus думает, Sonnet пишет код
```

### Конкретные промпты вместо расплывчатых

```bash
# ❌ Дорого — сканирует всю кодовую базу
"улучши проект"

# ✅ Эффективно — точечный результат
"добавь валидацию email в registerUser в src/auth/register.ts"
```

### Ключевые приёмы

- **Plan Mode** (Shift+Tab) перед реализацией — предотвращает дорогую переделку
- **Субагенты** для ресурсоёмких операций (тесты, исследование) — изолированный контекст
- **`/compact` при 60–80%** — не ждите автокомпакции на 95%, она теряет больше
- **`/clear` между задачами** — чистый контекст для каждой задачи
- **Batch-промпты** — группировка связанных правок в один запрос

---

## FAQ

<details>
<summary><strong>Работает ли на Windows?</strong></summary>

Да, через WSL (Windows Subsystem for Linux). Откройте WSL-терминал и запустите скрипт как обычно. VSCode с Claude Code подключается к WSL нативно.
</details>

<details>
<summary><strong>Можно ли использовать с подпиской Pro?</strong></summary>

Да, методология полностью совместима с Pro. Рекомендуется экономить токены: модель Sonnet по умолчанию, Opus только для архитектуры, `/compact` при 60% контекста.
</details>

<details>
<summary><strong>Обязательно ли использовать все файлы?</strong></summary>

Нет. Уровень 1 (Minimal) — это 80% пользы за 20% усилий. Начните с него, добавляйте Memory Bank и ADR по мере роста проекта.
</details>

<details>
<summary><strong>Как добавить Forge к существующему проекту?</strong></summary>

Запустите скрипт в отдельной директории, затем скопируйте нужные файлы (`.claude/`, `CLAUDE.md`, `.claudeignore`) в существующий проект. Адаптируйте CLAUDE.md под свой стек и команды.
</details>

<details>
<summary><strong>Зачем Memory Bank, если у Claude Code есть встроенная память?</strong></summary>

Claude Code сам по себе не сохраняет долговременной памяти между сессиями — каждая сессия начинается с чистого контекста, в который подгружается только CLAUDE.md и явно указанные файлы. Memory Bank — это **ваша** структурированная персистентная память с 6 специализированными файлами, которые вы и Claude обновляете осознанно и явно загружаете в начале сессии (через `/freshstart` или ссылки из CLAUDE.md).
</details>

<details>
<summary><strong>Как обновить методологию в существующем проекте?</strong></summary>

Скачайте новую версию скрипта и запустите в отдельной директории. Сравните сгенерированные файлы с текущими и перенесите изменения вручную — ваш CLAUDE.md и memory bank содержат уникальный контекст проекта, который нельзя перезаписывать.
</details>

---

## Источники и благодарности

Методология v3.0 (май 2026) синтезирована из официальной документации Anthropic, эмпирических исследований и доказанных практик сообщества:

### Официальная документация

- [Claude Code docs](https://code.claude.com/docs/en/) — актуальная (2026) документация Anthropic
- [Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) — рекомендации Anthropic
- [Hooks reference](https://code.claude.com/docs/en/hooks) — все 28+ hook events, JSON-схема, exit-коды
- [Skills](https://code.claude.com/docs/en/skills) — `.claude/skills/<name>/SKILL.md` спецификация
- [Subagents](https://code.claude.com/docs/en/sub-agents) — `.claude/agents/*.md`
- [Memory](https://code.claude.com/docs/en/memory) — CLAUDE.md hierarchy, `@`-imports, path-scoped rules
- [Permissions](https://code.claude.com/docs/en/permissions) — allow/deny/ask, glob patterns, read-only commands
- [Headless mode](https://code.claude.com/docs/en/headless) — `claude --bare -p` для CI/CD
- [Sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing) — изоляция autonomous runs

### Эмпирические исследования

- [METR RCT (July 2025)](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/) — реальное влияние AI на опытных разработчиков
- [DORA 2025 State of AI-assisted Software Development](https://dora.dev/dora-report-2025/) — DevOps метрики
- [AI-Generated Code Has 1.7× More Bugs (Shiplight)](https://www.shiplight.ai/blog/ai-generated-code-has-more-bugs)
- [Slopsquatting (Trend Micro)](https://www.trendmicro.com/vinfo/us/security/news/cybercrime-and-digital-threats/slopsquatting-when-ai-agents-hallucinate-malicious-packages) — 19.7% hallucinated packages
- arXiv 2509.14744 — анализ 253 CLAUDE.md файлов в open source
- arXiv 2511.09268 — конфигурации AI coding agents (328 проектов)
- arXiv 2506.11442 — ReVeal: self-evolving code agents

### Практики сообщества

- [Writing a good CLAUDE.md (HumanLayer)](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Inside Shopify's AI-first engineering (Bessemer)](https://www.bvp.com/atlas/inside-shopifys-ai-first-engineering-playbook)
- [Trail of Bits Claude Code config](https://github.com/trailofbits/claude-code-config) — security-focused setup
- [Simon Willison: agentic engineering patterns](https://simonwillison.net/guides/agentic-engineering-patterns/linear-walkthroughs/)
- [Kent Beck on spec-driven dev](https://www.linkedin.com/posts/kentbeck_the-descriptions-of-spec-driven-development-activity-7413956151144542208-EGMz)
- [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD)
- [Memory Bank (Cline)](https://github.com/cline/prompts)
- [The ADR Pattern for Claude](https://7tonshark.com/posts/claude-adr-pattern/)
- [Plan Mode Guide 2026](https://www.vibecodingacademy.ai/blog/claude-code-plan-mode-complete-guide)
- [Docker Sandboxes for Claude Code](https://www.docker.com/blog/docker-sandboxes-run-claude-code-and-other-coding-agents-unsupervised-but-safely/)

---

## Содействие

Pull requests приветствуются. Особенно интересны:

- Новые пресеты тех-стеков (Go, Rust, PHP/Laravel, и т.д.)
- Кастомные slash-команды для специфичных workflow
- Интеграции с CI/CD (GitHub Actions, GitLab CI)
- Переводы README на другие языки
- Реальные кейсы использования

---

## Лицензия

MIT — используйте свободно в личных и коммерческих проектах.

---

<p align="center">
  <em>Сделано с помощью Claude Code по собственной методологии 🔨</em>
</p>
