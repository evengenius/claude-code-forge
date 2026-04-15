# Stack: Custom (interactive input)
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
