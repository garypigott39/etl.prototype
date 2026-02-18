#!/usr/bin/env python3
"""
sqlcat.py

Determine dependency order of SQL files (tables, views, functions, procedures)
without requiring a live PostgreSQL database.

Schema-aware version.
"""

import os
import re
import sys
from collections import defaultdict, deque

import sqlparse
from sqlparse.sql import Identifier, IdentifierList
from sqlparse.tokens import Keyword


SQL_EXTENSIONS = (".sql",)
DEFAULT_SCHEMA = "public"


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
# Canonical Naming (Schema-Aware)
# ==========================================================

def normalize_name(name, default_schema=DEFAULT_SCHEMA):
    if not name:
        return None

    name = name.strip('"')

    if "." in name:
        schema, obj = name.split(".", 1)
        return f"{schema.lower()}.{obj.lower()}"

    return f"{default_schema.lower()}.{name.lower()}"


def normalize_identifier(identifier, default_schema=DEFAULT_SCHEMA):
    if not isinstance(identifier, Identifier):
        return None

    schema = identifier.get_parent_name()
    name = identifier.get_real_name()

    if not name:
        return None

    if schema:
        return f"{schema.lower()}.{name.lower()}"

    return f"{default_schema.lower()}.{name.lower()}"


# ==========================================================
# Function Body Extraction
# ==========================================================

FUNCTION_BODY_PATTERN = re.compile(
    r"AS\s+(\$.*?\$)(.*?)\1",
    re.IGNORECASE | re.DOTALL,
)


def extract_function_bodies(sql_text):
    return [match[1] for match in FUNCTION_BODY_PATTERN.findall(sql_text)]


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
            name = normalize_identifier(token)
            if name:
                created.append(name)
            break

    return created


# ==========================================================
# Extract Trigger Definitions
# ==========================================================

def extract_triggers(statement):
    """
    Detect CREATE TRIGGER statements and return referenced objects:
      - table (after ON)
      - function (after EXECUTE FUNCTION/PROCEDURE)

    IMPORTANT:
    Triggers are NOT schema-level objects in PostgreSQL.
    They belong to tables.
    So we DO NOT register them as created objects.
    """
    refs = set()

    if statement.get_type() != "CREATE":
        return refs

    if "TRIGGER" not in statement.value.upper():
        return refs

    tokens = list(statement.tokens)

    table_name = None
    function_name = None

    i = 0
    while i < len(tokens):
        token = tokens[i]

        # ON <table>
        if token.ttype is Keyword and token.value.upper() == "ON":
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]
                if next_token.is_whitespace:
                    j += 1
                    continue

                if isinstance(next_token, Identifier):
                    table_name = normalize_identifier(next_token)
                else:
                    table_name = normalize_name(next_token.value)
                break

        # EXECUTE FUNCTION <func>
        if token.ttype is Keyword and token.value.upper() == "EXECUTE":
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]

                if next_token.is_whitespace:
                    j += 1
                    continue

                if next_token.ttype is Keyword and next_token.value.upper() in ("FUNCTION", "PROCEDURE"):
                    j += 1
                    continue

                if isinstance(next_token, Identifier):
                    function_name = normalize_identifier(next_token)
                else:
                    function_name = normalize_name(next_token.value)
                break

        i += 1

    if table_name:
        refs.add(table_name)

    if function_name:
        refs.add(function_name)

    return refs


# ==========================================================
# Extract References (FROM / JOIN)
# ==========================================================

def extract_references_from_statement(statement):
    refs = set()
    tokens = list(statement.tokens)

    i = 0
    while i < len(tokens):
        token = tokens[i]

        if token.ttype is Keyword and (
            token.value.upper() == "FROM"
            or "JOIN" in token.value.upper()
        ):
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]

                if next_token.is_whitespace:
                    j += 1
                    continue

                if isinstance(next_token, IdentifierList):
                    for identifier in next_token.get_identifiers():
                        name = normalize_identifier(identifier)
                        if name:
                            refs.add(name)
                    break

                if isinstance(next_token, Identifier):
                    name = normalize_identifier(next_token)
                    if name:
                        refs.add(name)
                    break

                break

        if token.is_group:
            refs.update(extract_references_from_statement(token))

        i += 1

    return refs


# ==========================================================
# Extract Function Calls
# ==========================================================

def extract_function_calls(statement):
    refs = set()
    tokens = list(statement.flatten())

    for i, token in enumerate(tokens):
        if token.value == "(" and i > 0:
            prev = tokens[i - 1]

            if isinstance(prev, Identifier):
                name = normalize_identifier(prev)
                if name:
                    refs.add(name)

            elif prev.ttype is None:
                name = normalize_name(prev.value)
                if name and "." in name:
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
            j = i + 1
            while j < len(tokens):
                next_token = tokens[j]
                if next_token.is_whitespace:
                    j += 1
                    continue

                name = normalize_name(next_token.value)
                if name:
                    refs.add(name)
                break

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

    for statement in statements:
        created_objects.extend(extract_created_objects(statement))

        trigger_refs = extract_triggers(statement)
        referenced_objects.update(trigger_refs)

        referenced_objects.update(extract_references_from_statement(statement))
        referenced_objects.update(extract_function_calls(statement))
        referenced_objects.update(extract_reference_constraints(statement))

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

    # Map created objects
    for file in sql_files:
        created_objects, _ = extract_dependencies(file)
        for obj in created_objects:
            if obj in object_to_file:
                raise Exception(f"Duplicate object definition: {obj}")
            object_to_file[obj] = file

    # Map references
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
