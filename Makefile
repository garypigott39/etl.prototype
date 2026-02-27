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
UTILS :=   # Python utils not yet defined, but this is where they would go

# Combined
ALL_CODE := $(DJANGO) $(SCRIPTS) $(UTILS)

# ---- Help ----
.PHONY: help
help:
	@clear
	@echo
	@echo "Available targets:"
	@echo "  make run               - Run Django dev server"
	@echo "  make migrate           - Apply migrations"
	@echo "  make makemigrations    - Make migrations"
	@echo "  make shell             - Django shell"
	@echo "  make test              - Run Django tests"
	@echo
	@echo "  make lint              - Lint all code"
	@echo "  make lint-django       - Lint only Django apps"
	@echo "  make lint-python       - Lint only non-Django Python"
	@echo
	@echo "  make format            - Auto-format all code"
	@echo "  make format-django     - Auto-format Django code"
	@echo "  make format-python     - Auto-format non-Django Python"
	@echo
	@echo "  make typecheck         - Type-check all code"
	@echo "  make typecheck-django  - Type-check Django apps"
	@echo "  make typecheck-python  - Type-check non-Django Python"
	@echo
	@echo "  make check             - Run lint + typecheck on everything"
	@echo "  make check-django      - Run lint + typecheck on Django apps"
	@echo "  make check-python      - Run lint + typecheck on non-Django Python"
	@echo
	@echo "  make fix-django        - Run 'mypy --fix' on Django apps"
	@echo "  make fix-python        - Run 'mypy --fix' on non-Django Python"
	@echo

# ---- Django Commands ----
.PHONY: run migrate makemigrations shell test
run: 
	@clear
	$(MANAGE) runserver

migrate: 
	@clear
	$(MANAGE) migrate

makemigrations: 
	@clear
	$(MANAGE) makemigrations

shell: 
	@clear
	$(MANAGE) shell

test: 
	@clear
	$(MANAGE) test

# ---- Linting ----
.PHONY: lint lint-django lint-python format format-django format-python
lint: lint-django lint-python

lint-django: 
	@clear
	ruff check $(DJANGO)

lint-python: 
	@clear
	ruff check $(SCRIPTS) $(UTILS)

format: format-django format-python

format-django: 
	@clear
	ruff check --fix $(ALL_CODE)
	ruff format $(ALL_CODE)

format-python: 
	@clear
	ruff check --fix $(SCRIPTS) $(UTILS)
	ruff format $(SCRIPTS) $(UTILS)

# ---- Type Checking ----
.PHONY: typecheck typecheck-django typecheck-python
typecheck: typecheck-django typecheck-python

typecheck-django:
	@clear
	mypy $(DJANGO)

typecheck-python:
	@clear
	mypy $(SCRIPTS) $(UTILS)


# ---- Type Checking ----
.PHONY: fix-django fix-python
fix-django:
	@clear
	mypy $(DJANGO) --fix

fix-python:
	@clear
	mypy $(SCRIPTS) $(UTILS) --fix

# ---- Combined ----
.PHONY: check check-django check-python
check: lint typecheck

check-django: lint-django typecheck-django

check-python: lint-python typecheck-python
