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
