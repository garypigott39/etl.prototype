#
# @file
# Makefile for prototype project
#
# ---- Config ----
PYTHON ?= python3
MANAGE := $(PYTHON) manage.py

# Directories
DJANGO := app
SCRIPTS := scripts
UTILS := utils

# Combined
ALL_CODE := $(DJANGO) $(SCRIPTS) $(UTILS)

# ---- Clear screen ----
.PHONY: clear
clear:
	@clear

# ---- Help ----
.PHONY: help
help: clear
	@echo "Available targets:"
	@echo "  make run             - Run Django dev server"
	@echo "  make migrate         - Apply migrations"
	@echo "  make makemigrations  - Make migrations"
	@echo "  make shell           - Django shell"
	@echo "  make test            - Run Django tests"
	@echo "  make lint            - Lint all code"
	@echo "  make lint-django     - Lint only Django apps"
	@echo "  make lint-python     - Lint only non-Django Python"
	@echo "  make format-django   - Auto-format Django code"
	@echo "  make format-python   - Auto-format non-Django Python"
	@echo "  make typecheck       - Type-check all code"
	@echo "  make check           - Run lint + typecheck on everything"

# ---- Django Commands ----
.PHONY: run migrate makemigrations shell test
run: clear
	$(MANAGE) runserver

migrate: clear
	$(MANAGE) migrate

makemigrations: clear
	$(MANAGE) makemigrations

shell: clear
	$(MANAGE) shell

test: clear
	$(MANAGE) test

# ---- Linting ----
.PHONY: lint lint-django lint-python format
lint-django: clear
	ruff check $(DJANGO)

lint-python: clear
	ruff check $(SCRIPTS) $(UTILS)

lint: clear
	lint-django lint-python

format-django: clear
	ruff check --fix $(ALL_CODE)
	ruff format $(ALL_CODE)

format-python: clear
	ruff check --fix $(ALL_CODE)
	ruff format $(SCRIPTS) $(UTILS)

# ---- Type Checking ----
.PHONY: typecheck
typecheck: clear
	mypy $(ALL_CODE)

# ---- Combined ----
.PHONY: check
check: clear
	lint typecheck
