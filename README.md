<p align="center">
  <img src="https://img.shields.io/badge/Claude_Code-v2.0-6C47FF?style=for-the-badge&logo=anthropic&logoColor=white" alt="Claude Code">
  <img src="https://img.shields.io/badge/VSCode-Extension-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white" alt="VSCode">
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
| Секреты попадают в контекст | Нет защиты чувствительных файлов | `permissions.deny` + `.claudeignore` + хук блокировки опасных команд |
| Проект разваливается при возврате через неделю | Контекст хранится «в голове» | Handoff-документы + memory bank + именованные сессии |
| Claude делает всё сразу и плохо | Задачи слишком крупные | Декомпозиция на «intern-sized» задачи (1–4 часа) с зависимостями |

**Claude Code Forge** — это bootstrap-скрипт + методология, которые за одну команду создают полную инфраструктуру для структурированной разработки любой сложности.

---

## Быстрый старт

### Требования

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (установлен и авторизован)
- VSCode с расширением Claude Code
- Подписка Pro / Max / Team / Enterprise
- bash (Linux, macOS, WSL)
- git

### Установка и запуск

```bash
# Скачать скрипт
curl -fsSL https://raw.githubusercontent.com/Evengenius/claude-code-forge/main/init-claude-project.sh -o init-claude-project.sh
chmod +x init-claude-project.sh

# Создать проект
./init-claude-project.sh my-project
```

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
# или выполните: /project:freshstart
```

---

## Что создаёт скрипт

### Уровень 1 — Minimal

```
my-project/
├── CLAUDE.md                      # Главный файл инструкций (40-50 строк)
├── CLAUDE.local.md                # Личные настройки (в .gitignore)
├── .claudeignore                  # Исключения из контекста Claude
├── .claude/
│   ├── settings.json              # Permissions + hooks (авто-формат, авто-тесты)
│   ├── commands/                  # 8 кастомных slash-команд
│   │   ├── plan.md                #   /project:plan — планирование задачи
│   │   ├── implement.md           #   /project:implement — TDD-реализация
│   │   ├── handoff.md             #   /project:handoff — передача контекста
│   │   ├── review.md              #   /project:review — code review
│   │   ├── freshstart.md          #   /project:freshstart — начало сессии
│   │   ├── compact-save.md        #   /project:compact-save — безопасная компакция
│   │   └── security-audit.md      #   /project:security-audit — аудит безопасности
│   └── rules/                     # Модульные правила
│       ├── testing.md             #   Правила тестирования (path-scoped)
│       ├── security.md            #   Правила безопасности
│       └── git.md                 #   Правила Git
├── PRD.md                         # Product Requirements Document
├── PLANNING.md                    # Архитектура и процесс
├── TASKS.md                       # Задачи с зависимостями
├── docs/
│   └── ARCHITECTURE.md            # Архитектурный обзор
├── src/                           # Исходный код
└── .gitignore
```

### Уровень 2 — Standard (добавляет к Minimal)

```
├── memory-bank/                   # Персистентная память между сессиями
│   ├── projectbrief.md            #   Цели, scope, ограничения
│   ├── productContext.md           #   Продуктовые требования, UX
│   ├── systemPatterns.md          #   Архитектурные паттерны
│   ├── techContext.md             #   Стек, зависимости, окружение
│   ├── activeContext.md           #   Текущий фокус работы
│   └── progress.md                #   Прогресс и known issues
├── adr/                           # Architecture Decision Records
│   └── 000-template.md            #   Шаблон ADR
├── _todo/                         # Handoff-документы и TPP
├── _done/                         # Завершённые handoff (в .gitignore)
└── .claude/commands/
    └── adr.md                     #   /project:adr — создание ADR
```

### Уровень 3 — Full (добавляет к Standard)

```
├── .claude/
│   ├── quality-gates/
│   │   └── architecture-gate.md   # Чек-лист на 10 пунктов (проходной балл: 90/100)
│   └── commands/
│       └── gate-check.md          #   /project:gate-check — проверка Quality Gate
└── specs/                         # Спецификации
```

---

## Методология

### Ключевые принципы

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ВАЙБ-КОДИНГ          →        FORGE-МЕТОДОЛОГИЯ          │
│                                                             │
│   «Сделай мне фичу»    →   Plan → Implement → Verify       │
│   Надежда на CLAUDE.md  →   Детерминистические хуки         │
│   Контекст в голове     →   Memory Bank + Handoff           │
│   Тесты потом           →   TDD: RED → GREEN → REFACTOR    │
│   Одна гигантская сессия →  Задачи по 1-4 часа             │
│   «Claude, не забудь»   →   Quality Gates + автопроверки    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Иерархия CLAUDE.md

Claude Code поддерживает 4 уровня конфигурации (загружаются снизу вверх, все конкатенируются):

| Приоритет | Файл | Назначение |
|-----------|------|-----------|
| 1 (высший) | `CLAUDE.local.md` | Личные настройки проекта (в .gitignore) |
| 2 | `CLAUDE.md` | Командные правила проекта (в git) |
| 3 | `~/.claude/CLAUDE.md` | Глобальные личные предпочтения |
| 4 (низший) | Managed Policy | Корпоративные правила (если применимо) |

**Бюджет инструкций**: Claude стабильно выполняет ~150–200 инструкций суммарно, из которых ~50 уже заняты системным промптом. Ваш бюджет — **100–150 правил** на всё. Forge держит CLAUDE.md в пределах 40–60 строк, вынося остальное в `.claude/rules/` (загружаются по path-scope) и хуки (детерминистические, не тратят бюджет).

### Система хуков

Хуки — это реальный код, который невозможно обойти, в отличие от инструкций в CLAUDE.md. Forge настраивает три типа:

**PostToolUse** — после каждого редактирования файла:
- Автоматическое форматирование (Prettier / Ruff)
- Автоматический линтинг (ESLint / Ruff)

**PreToolUse** — перед выполнением bash-команды:
- Блокировка `rm -rf /`, `git push --force main`, `DROP TABLE`

**Stop** — когда Claude считает задачу завершённой:
- Автозапуск тест-сьюта (если тесты падают — Claude продолжает работу)

### Управление контекстом

Контекстное окно — **главный ограниченный ресурс**. Методология управляет им на трёх уровнях:

**Превентивный** — не допускать переполнения:
- `.claudeignore` исключает node_modules, билды, логи, данные
- `permissions.deny` блокирует чтение секретов
- Задачи размером 1–4 часа (не 8-часовые марафоны)
- `/clear` между несвязанными задачами

**Оперативный** — при заполнении 60–80%:
- `/project:compact-save` — сохранить важное перед компакцией
- `/compact [инструкция]` — сжатие с указанием что сохранить
- Субагенты для ресурсоёмких операций (тесты, исследование)

**Межсессионный** — сохранение контекста между сессиями:
- Memory Bank (6 файлов) — автоматически загружается при старте
- Handoff-документы в `_todo/` — структурированная передача контекста
- ADR — архитектурные решения не пересматриваются заново

### TDD-цикл

Forge навязывает Test-Driven Development через команду `/project:implement` и правила в `.claude/rules/testing.md`:

```
RED:      Напиши ОДИН падающий тест. Запусти — убедись что падает.
GREEN:    Напиши МИНИМАЛЬНЫЙ код для прохождения. Запусти — проходит.
REFACTOR: Улучши код, проверяя тесты после каждого шага.
REPEAT.
```

Stop-хук автоматически запускает тест-сьют каждый раз, когда Claude считает задачу завершённой. Если тесты падают — Claude получает вывод ошибок и продолжает работу.

### Architecture Decision Records (ADR)

Каждое нетривиальное архитектурное решение записывается в отдельный файл `adr/NNN-slug.md` со структурой: Context → Decision → Alternatives Considered → Consequences.

Это решает проблему «почему мы выбрали X?» — Claude читает ADR вместо повторного обсуждения. Команда `/project:adr` автоматизирует создание.

### Quality Gates (уровень Full)

Перед переходом от планирования к реализации `/project:gate-check` проверяет 10 обязательных пунктов:

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

### Slash-команды Claude Code

| Команда | Описание | Когда использовать |
|---------|----------|-------------------|
| `/project:freshstart` | Загрузить весь контекст проекта, показать статус и рекомендовать следующую задачу | В начале каждой рабочей сессии |
| `/project:plan [задача]` | Спланировать реализацию с учётом ADR и зависимостей | Перед началом любой задачи >30 мин |
| `/project:implement [задача]` | Реализовать по TDD-циклу (RED→GREEN→REFACTOR) | Непосредственно реализация |
| `/project:review [scope]` | Code review с классификацией замечаний (🔴🟡🔵) | После завершения фичи, перед мержем |
| `/project:handoff` | Создать handoff-документ для следующей сессии | В конце каждой рабочей сессии |
| `/project:compact-save` | Сохранить важный контекст перед компакцией | При заполнении контекста на 60–80% |
| `/project:adr [тема]` | Создать Architecture Decision Record | При принятии архитектурного решения |
| `/project:security-audit [scope]` | Проверить секреты, SQL injection, XSS, зависимости | Периодически и перед релизом |
| `/project:gate-check` | Проверка Quality Gate (90/100) | Перед переходом к реализации (Full) |

### Встроенные команды Claude Code

| Команда | Описание |
|---------|----------|
| `/compact [инструкция]` | Сжать историю, сохранив указанный контекст |
| `/clear` | Полная очистка истории сессии |
| `/context` | Показать распределение токенов |
| `/cost` | Показать расход токенов за сессию |
| `/model sonnet\|opus` | Переключить модель (sonnet — экономия, opus — сложные задачи) |
| `/effort low\|high\|max` | Уровень глубины рассуждений |
| `Shift+Tab` | Переключить Plan Mode (исследование без изменений) |

### Рекомендуемый ежедневный workflow

```
Утро:
  /project:freshstart              ← загрузить контекст, увидеть статус
  Выбрать задачу из TASKS.md
  /project:plan [задача]           ← спланировать в Plan Mode

Работа:
  /project:implement [задача]      ← TDD-реализация
  ...при 60-80% контекста...
  /project:compact-save            ← сохранить перед компакцией
  /compact [инструкция]            ← сжать

Завершение:
  /project:review                  ← самоконтроль
  /project:handoff                 ← сохранить контекст
  git commit                       ← зафиксировать
```

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

Отредактируйте `.claude/settings.json`, секция `hooks`:

```jsonc
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "your-formatter \"$CLAUDE_FILE_PATH\""
      }
    ]
  }
}
```

### Добавить свои правила

Создайте файл в `.claude/rules/` с YAML-frontmatter для path-scoping:

```yaml
# .claude/rules/api-validation.md
---
paths:
  - "src/api/**/*.ts"
---
# Все API-эндпоинты должны валидировать вход через zod-схему
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

Вызов: `/project:deploy staging`

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

Встроенная Auto Memory (`~/.claude/projects/*/MEMORY.md`) ограничена 200 строками и управляется автоматически — вы не контролируете, что сохраняется. Memory Bank — это **ваша** структурированная память с 6 специализированными файлами, которые вы и Claude обновляете осознанно.
</details>

<details>
<summary><strong>Как обновить методологию в существующем проекте?</strong></summary>

Скачайте новую версию скрипта и запустите в отдельной директории. Сравните сгенерированные файлы с текущими и перенесите изменения вручную — ваш CLAUDE.md и memory bank содержат уникальный контекст проекта, который нельзя перезаписывать.
</details>

---

## Источники и благодарности

Методология синтезирована из лучших практик сообщества:

- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code) — официальная документация Anthropic
- [Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — анализ системного промпта и бюджета инструкций
- [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) — agile-фреймворк для AI-разработки
- [Taskmaster-AI](https://github.com/eyaltoledano/claude-task-master) — управление задачами с зависимостями
- [Memory Bank (Cline)](https://github.com/cline/prompts) — паттерн персистентной памяти
- [The ADR Pattern for Claude](https://7tonshark.com/posts/claude-adr-pattern/) — архитектурные решения как память
- [Claude Code TPP](https://photostructure.com/coding/claude-code-tpp/) — Technical Project Plans
- [Workflows for agentic coding](https://russpoldrack.substack.com/p/workflows-for-agentic-coding-and) — структурированные workflow
- [Beyond Vibe-Coding (InnoGames)](https://blog.innogames.com/beyond-vibe-coding-a-disciplined-workflow-for-ai-assisted-software-development-with-claude-code/) — дисциплинированный подход

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
