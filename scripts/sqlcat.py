#
# @file
# sqlcat.py
#
# Cat all SQL files in a folder and subfolders in dependency order.
# Thanks to @ChatGPT - see https://chat.openai.com/share/1b9c8e7c-5a0d-4f2e-9b3c-1a0e5d8f1c6b
#

import os
import re
from collections import defaultdict, deque

SQL_EXTENSIONS = (".sql",)

CREATE_PATTERN = re.compile(
    r"CREATE\s+(TABLE|VIEW|FUNCTION|PROCEDURE)\s+(?:IF\s+NOT\s+EXISTS\s+)?([a-zA-Z0-9_.]+)",
    re.IGNORECASE
)

REFERENCE_PATTERN = re.compile(
    r"REFERENCES\s+([a-zA-Z0-9_.]+)",
    re.IGNORECASE
)

FROM_JOIN_PATTERN = re.compile(
    r"(?:FROM|JOIN)\s+([a-zA-Z0-9_.]+)",
    re.IGNORECASE
)


def scan_sql_files(parent_folder):
    """Recursively find all .sql files in folder and subfolders."""
    sql_files = []
    for root, _, files in os.walk(parent_folder):
        for file in files:
            if file.lower().endswith(SQL_EXTENSIONS):
                sql_files.append(os.path.join(root, file))
    return sql_files


def extract_dependencies(file_path):
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    creates = CREATE_PATTERN.findall(content)
    references = REFERENCE_PATTERN.findall(content)
    from_join_refs = FROM_JOIN_PATTERN.findall(content)

    created_objects = [obj[1].lower() for obj in creates]
    referenced_objects = set(
        ref.lower() for ref in (references + from_join_refs)
    )

    return created_objects, referenced_objects


def build_dependency_graph(sql_files):
    object_to_file = {}
    file_dependencies = defaultdict(set)

    # Initialize dependency graph for ALL files
    for file in sql_files:
        file_dependencies[file] = set()

    # First pass: map created objects to files
    for file in sql_files:
        created_objects, _ = extract_dependencies(file)
        for obj in created_objects:
            object_to_file[obj] = file

    # Second pass: build dependencies
    for file in sql_files:
        _, referenced_objects = extract_dependencies(file)
        for ref in referenced_objects:
            ref_file = object_to_file.get(ref)
            if ref_file and ref_file != file:
                file_dependencies[file].add(ref_file)

    return file_dependencies


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


def print_files_in_order(ordered_files):
    n = 0
    for file_path in ordered_files:
        n += 1
        print(f"\n-- {n}. {file_path}")

        with open(file_path, "r", encoding="utf-8") as f:
            print(f.read())

        print(f"\n-- EOF: {file_path}")


def main(parent_folder):
    sql_files = scan_sql_files(parent_folder)

    if not sql_files:
        print("No SQL files found.")
        return

    dependencies = build_dependency_graph(sql_files)
    ordered_files = topological_sort(dependencies)
    print_files_in_order(ordered_files)


if __name__ == "__main__":
    import sys

    if len(sys.argv) != 2:
        print("Usage: python order_sql.py <parent_sql_folder>")
        sys.exit(1)

    main(sys.argv[1])
