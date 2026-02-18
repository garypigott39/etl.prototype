#!/usr/bin/env python3
"""
sqlcat.py

Determine dependency order of SQL files (tables, views, functions, procedures)
without requiring a live PostgreSQL database. Uses sqlparse for token-aware parsing.

Thanks to ChatGPT for the initial implementation!

Usage:
    py sqlcat.py <parent_sql_folder>
"""

import os
import re
import sys
from collections import defaultdict, deque

import sqlparse
from sqlparse.sql import Identifier, IdentifierList
from sqlparse.tokens import Keyword


SQL_EXTENSIONS = (".sql",)


# ==========================================================
# Utility: Scan Files
# ==========================================================

def scan_sql_files(parent_folder):
    sql_files = []
    for root, _, files in os.walk(parent_folder):
        for file in files:
            if file.lower().endswith(SQL_EXTENSIONS):
                sql_files.append(os.path.join(root, file))
    return sql_files


# ==========================================================
# Function Body Extraction ($$ or $tag$)
# ==========================================================

FUNCTION_BODY_PATTERN = re.compile(
    r"AS\s+(\$.*?\$)(.*?)\1",
    re.IGNORECASE | re.DOTALL,
)


def extract_function_bodies(sql_text):
    return [match[1] for match in FUNCTION_BODY_PATTERN.findall(sql_text)]


# ==========================================================
# Identifier Extraction
# ==========================================================

def extract_identifiers(token):
    if isinstance(token, IdentifierList):
        for identifier in token.get_identifiers():
            yield identifier.get_real_name()
    elif isinstance(token, Identifier):
        yield token.get_real_name()


def normalize_name(name):
    if not name:
        return None
    return name.split(".")[-1].strip('"').lower()


# ==========================================================
# Extract Created Objects
# ==========================================================

def extract_created_objects(statement):
    created = []

    if statement.get_type() != "CREATE":
        return created

    seen_keyword = False

    for token in statement.tokens:
        if token.ttype is Keyword:
            seen_keyword = True
            continue

        if seen_keyword and isinstance(token, Identifier):
            name = normalize_name(token.get_real_name())
            if name:
                created.append(name)
            break

    return created


# ==========================================================
# Extract Trigger Definitions (Robust, Schema-aware)
# ==========================================================

def extract_triggers(statement):
    """
    Detect CREATE TRIGGER statements and return:
      - created trigger name
      - referenced table (after ON)
      - referenced function (after EXECUTE FUNCTION/PROCEDURE)

    Handles schema-qualified names like:
        ce_etl.x_value
        ce_etl.fx_tg_x_value_audit()
    """
    created = []
    refs = set()

    if statement.get_type() != "CREATE":
        return created, refs

    # Must contain TRIGGER keyword
    if "TRIGGER" not in statement.value.upper():
        return created, refs

    tokens = list(statement.tokens)

    trigger_name = None
    table_name = None
    function_name = None

    i = 0
    while i < len(tokens):
        token = tokens[i]

        # -----------------------------
        # CREATE TRIGGER <name>
        # -----------------------------
        if token.ttype is Keyword and token.value.upper() == "TRIGGER":
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]

                if next_token.is_whitespace:
                    j += 1
                    continue

                if isinstance(next_token, Identifier):
                    trigger_name = normalize_name(next_token.get_real_name())
                else:
                    trigger_name = normalize_name(next_token.value)

                break

        # -----------------------------
        # ON <table>
        # -----------------------------
        if token.ttype is Keyword and token.value.upper() == "ON":
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]

                if next_token.is_whitespace:
                    j += 1
                    continue

                if isinstance(next_token, Identifier):
                    table_name = normalize_name(next_token.get_real_name())
                else:
                    table_name = normalize_name(next_token.value)

                break

        # -----------------------------
        # EXECUTE FUNCTION <func>
        # -----------------------------
        if token.ttype is Keyword and token.value.upper() == "EXECUTE":
            j = i + 1
            while j < len(tokens):

                next_token = tokens[j]

                if next_token.is_whitespace:
                    j += 1
                    continue

                # Skip FUNCTION / PROCEDURE keyword
                if next_token.ttype is Keyword and next_token.value.upper() in ("FUNCTION", "PROCEDURE"):
                    j += 1
                    continue

                if isinstance(next_token, Identifier):
                    function_name = normalize_name(next_token.get_real_name())
                else:
                    function_name = normalize_name(next_token.value)

                break

        i += 1

    if trigger_name:
        created.append(trigger_name)

    if table_name:
        refs.add(table_name)

    if function_name:
        refs.add(function_name)

    return created, refs


# ==========================================================
# Extract Function Calls
# ==========================================================

def extract_function_calls(statement):
    refs = set()

    tokens = list(statement.flatten())

    for i, token in enumerate(tokens):
        # Detect function call pattern: name (
        if token.ttype is None and token.value == "(":
            if i > 0:
                prev = tokens[i - 1]

                # Only consider identifiers
                if isinstance(prev, Identifier):
                    name = prev.get_real_name()
                    if name:
                        refs.add(normalize_name(name))

                # Or plain name token (schema.func)
                elif prev.ttype is None:
                    name = normalize_name(prev.value)
                    if name and name.isidentifier():
                        refs.add(name)

    return refs


# ==========================================================
# Extract Reference Constraints
# ==========================================================


def extract_reference_constraints(statement):
    refs = set()
    tokens = list(statement.flatten())

    for i, token in enumerate(tokens):
        if token.ttype is Keyword and token.value.upper() == "REFERENCES":
            # Look ahead for table name
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]

                if next_token.is_whitespace:
                    j += 1
                    continue

                # If schema-qualified name
                name = normalize_name(next_token.value)
                if name:
                    refs.add(name)

                break

    return refs


# ==========================================================
# Extract Table & Function Usage
# ==========================================================

JOIN_KEYWORDS = {
    "FROM",
    "JOIN",
    "LEFT JOIN",
    "RIGHT JOIN",
    "INNER JOIN",
    "OUTER JOIN",
    "FULL JOIN",
    "CROSS JOIN",
}


def extract_references_from_statement(statement):
    refs = set()
    tokens = list(statement.tokens)

    i = 0
    while i < len(tokens):
        token = tokens[i]

        # Detect FROM / JOIN keywords
        if token.ttype is Keyword and "JOIN" in token.value.upper() or token.value.upper() == "FROM":
            # Look ahead for next meaningful token
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]

                # Skip whitespace & noise
                if next_token.is_whitespace:
                    j += 1
                    continue

                # Skip LATERAL
                if next_token.ttype is Keyword and next_token.value.upper() == "LATERAL":
                    j += 1
                    continue

                # If IdentifierList (FROM a, b)
                if isinstance(next_token, IdentifierList):
                    for identifier in next_token.get_identifiers():
                        name = identifier.get_real_name()
                        if name:
                            refs.add(normalize_name(name))
                    break

                # If single Identifier
                if isinstance(next_token, Identifier):
                    name = next_token.get_real_name()
                    if name:
                        refs.add(normalize_name(name))
                    break

                # If function (e.g., UNNEST(...)) ignore
                if next_token.is_group:
                    break

                break

        # Recurse into subqueries
        if token.is_group:
            refs.update(extract_references_from_statement(token))

        i += 1

    return refs


# ==========================================================
# Extract Dependencies Per File
# ==========================================================

def extract_dependencies(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    statements = sqlparse.parse(content)

    created_objects = []
    referenced_objects = set()

    # Top-level statements
    for statement in statements:
        created_objects.extend(extract_created_objects(statement))

        # Trigger support
        trigger_created, trigger_refs = extract_triggers(statement)
        created_objects.extend(trigger_created)
        referenced_objects.update(trigger_refs)

        # General references
        referenced_objects.update(
            extract_references_from_statement(statement)
        )
        referenced_objects.update(
            extract_function_calls(statement)
        )
        referenced_objects.update(
            extract_reference_constraints(statement)
        )

    # Function bodies
    bodies = extract_function_bodies(content)

    for body in bodies:
        body_statements = sqlparse.parse(body)
        for stmt in body_statements:
            referenced_objects.update(
                extract_references_from_statement(stmt)
            )

    return created_objects, referenced_objects


# ==========================================================
# Build Dependency Graph
# ==========================================================

def build_dependency_graph(sql_files):
    object_to_file = {}
    file_dependencies = defaultdict(set)

    for file in sql_files:
        file_dependencies[file] = set()

    # Pass 1: map created objects
    for file in sql_files:
        created_objects, _ = extract_dependencies(file)
        for obj in created_objects:
            object_to_file[obj] = file

    # Pass 2: map references
    for file in sql_files:
        _, referenced_objects = extract_dependencies(file)

        for ref in referenced_objects:
            ref_file = object_to_file.get(ref)
            if ref_file and ref_file != file:
                file_dependencies[file].add(ref_file)

    return file_dependencies


# ==========================================================
# Topological Sort
# ==========================================================

def topological_sort(dependencies):
    in_degree = {file: 0 for file in dependencies}

    for file, deps in dependencies.items():
        for dep in deps:
            in_degree[file] += 1

    queue = deque([f for f in in_degree if in_degree[f] == 0])
    ordered = []

    while queue:
        current = queue.popleft()
        ordered.append(current)

        for file, deps in dependencies.items():
            if current in deps:
                in_degree[file] -= 1
                if in_degree[file] == 0:
                    queue.append(file)

    if len(ordered) != len(dependencies):
        raise Exception("Circular dependency detected!")

    return ordered


# ==========================================================
# Output
# ==========================================================

def print_files_in_order(ordered_files):
    for i, file_path in enumerate(ordered_files, 1):
        print(f"\n-- {i}. {file_path}\n")

        with open(file_path, "r", encoding="utf-8") as f:
            print(f.read())

        print(f"\n-- EOF: {file_path}")


# ==========================================================
# Main
# ==========================================================

def main(parent_folder):
    sql_files = scan_sql_files(parent_folder)

    if not sql_files:
        print("No SQL files found.")
        return

    dependencies = build_dependency_graph(sql_files)
    ordered_files = topological_sort(dependencies)
    print_files_in_order(ordered_files)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: py sqlcat.py <parent_sql_folder>")
        sys.exit(1)

    main(sys.argv[1])
