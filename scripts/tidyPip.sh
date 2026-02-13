#!/bin/bash

#------------------------------------------------------------------------------
# @file: tidyPip.sh
#
# Remove ununsed local packages from the pip cache.
#
# Called as:
#
#   tidyPip.sh  [--clean  optional clean up pip cache flag]
#------------------------------------------------------------------------------

cleanup=0

# Ensure running from root of the repository
if [[ ! -d .git ]]
then
    echo "Error: This script must be run from the root of the repository." >&2
    exit 1
elif [[ ! -s requirements.txt ]]
then
    echo "Error: No requirements.txt file found." >&2
    exit 1
fi

if [[ "$1" == "--clean" ]]
then
    cleanup=1
fi

# Get a list of unused packages
python3 <<EOF
import pkg_resources
import re
import subprocess
import sys

# Get names of installed packages
installed = {pkg.key for pkg in pkg_resources.working_set}

# Read requirements
required = {'pip', 'pydevd_pycharm', 'setuptools'}  # Start with known tools

regex = r'==|>=|<=|>|<'
for f in ('requirements.txt', 'requirements.dev.txt'):
    try:
        with open(f) as file:
            for line in file:
                line = line.strip()
                if line and not line.startswith('#'):
                    parts = re.split(regex, line)
                    name = parts[0].strip().lower()
                    required.add(name)
    except FileNotFoundError:
        pass

# Find packages that are installed but not required
extras = sorted(installed - required)
print("### Packages not in requirements:")
for pkg in sorted(extras):
    print(f"  {pkg}")


# Clean up?
cleanup = '${cleanup}' == '1'
if extras and cleanup:
    print("### Uninstalling unused packages...")
    subprocess.run(['pip', 'uninstall', '-y'] + list(extras))

    print("### Reinstalling requirements...")
    for f in ('requirements.txt', 'requirements.dev.txt'):
        try:
            subprocess.run(['pip', 'install', '-r', f])
        except FileNotFoundError:
            print(f"Warning: File {f} not found, skipping.")
EOF
