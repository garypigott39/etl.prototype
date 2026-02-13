#!/bin/bash

#------------------------------------------------------------------------------
# @file: setup.sh
#
# Initialize local repo with virtual env etc.
#
# Called as:
#
#   setup.sh [optional --force flag]
#------------------------------------------------------------------------------

FORCE=
if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
fi

if [[ ! -d scripts ]]
then
  echo "Error: This script should be run from the root of a repository." >&2
  exit 1
fi

# Clear down any existing .venv folder, but only if --force flag is provided
if [[ -d .venv ]]
then
  if [[ ! "${FORCE}" ]]
  then
    echo "Error: .venv folder already exists. Use --force to overwrite." >&2
    exit 1
  else
    rm -rf .venv
  fi
fi

# Create virtual environment and install dependencies
PYTHON_311=
for cmd in python3.11 python
do
  if command -v "${cmd}" #> /dev/null 2>&1
  then
    # Ensure its Python 3.11
    "${cmd}" -c 'import sys; exit(0 if sys.version_info[:2] == (3, 11) else 1)'
    if [[ $? -ne 0 ]]
    then
      echo "Warning: '${cmd}' is not Python 3.11, skipping." >&2
      continue
    fi
    PYTHON_311="${cmd}"
    break
  fi
done

if [[ ! "${PYTHON_311}" ]]
then
  echo "Error: Python 3.11 is required to run this script." >&2
  exit 1
fi

"${PYTHON_311}" -m venv .venv
if [[ $? -ne 0 ]]
then
  echo "Error: Failed to create virtual environment using ${PYTHON_311}." >&2
  exit 1
elif [[ ! -s .venv/bin/activate ]]
then
  echo "Error: Virtual environment activation script not found." >&2
  exit 1
fi

# Ensure the expected Python executables are present in the virtual environment
for cmd in python3.11 python3 python
do
  if [[ ! -s .venv/bin/${cmd} ]]
  then
    echo "Error: Python executable ${cmd} not found in virtual environment." >&2
    exit 1
  fi
done

# Set up "py" alias to point to the Python executable in the virtual environment
if [[ ! -s .venv/bin/py ]]
then
  cd .venv/bin  && ln -s python3.11 py && cd -
  if [[ $? -ne 0 ]]
  then
    echo "Error: Failed to create 'py' alias in virtual environment." >&2
    exit 1
  fi
fi

# Add PATH gubbins to activate script
#cat <<EOF >> .venv/bin/activate
#
## @GP add app to PYTHONPATH
#PYTHONPATH="${PYTHONPATH:-.}"
#export PYTHONPATH=$PYTHONPATH:$PWD/app
#EOF

# Activate the virtual environment and install dependencies
source .venv/bin/activate
if [[ $? -ne 0 ]]
then
  echo "Error: Failed to activate virtual environment." >&2
  exit 1
fi

pip install --upgrade pip
if [[ $? -ne 0 ]]
then
  echo "Error: Failed to upgrade pip." >&2
  exit 1
fi

# Clean up any existing dependencies in requirements.txt before installing
./scripts/tidyPip.sh

if [[ -s requirements.txt ]]
then
  pip install -r requirements.txt
  if [[ $? -ne 0 ]]
  then
    echo "Error: Failed to install dependencies from requirements.txt." >&2
    exit 1
  fi
fi

if [[ -s requirements.dev.txt ]]
then
  pip install -r requirements.dev.txt
  if [[ $? -ne 0 ]]
  then
    echo "Error: Failed to install dependencies from requirements.dev.txt." >&2
    exit 1
  fi
fi

# Create dummy local.settings.json for Azure Functions Core Tools to stop it complaining about missing file when running func commands locally
# Should be ignored by GIT (see .gitignore) so won't cause issues with commits etc.
#if [[ ! -s local.settings.json ]]
#then
#    cat <<EOF > local.settings.json
#{
#  "IsEncrypted": false,
#  "Values": {
#    "ENV": "local",
#    "FUNCTIONS_WORKER_RUNTIME": "python"
#  },
#  "ConnectionStrings": {},
#  "Host": {}
#}
#EOF
#fi

echo
echo "Initialization complete. Virtual environment created and dependencies installed."
echo