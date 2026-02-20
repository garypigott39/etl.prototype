#!/bin/bash

#------------------------------------------------------------------------------
# @file: dump.sh
#
# Run database dump locally. It is expected to be run via CLI.
#
# Called as:
#
#   dump.sh
#------------------------------------------------------------------------------

export USER=postgres
export PGPASSWORD=postgres

DB=prototype

RUNTIME=0

rm benchmark.txt 2> /dev/null

#------------------------------------- FUNCTIONS ------------------------------

function fatal()
{
  echo
  echo "##################################################################################"
  echo "## Fatal Error"
  echo "## $*"
  echo "## ${SCRIPTNAME}, Script abandoned @ $(date)"
  echo "##################################################################################"
  exit 1
}

#------------------------------------------------------------------------------

function ask()
{
  varname="$1"
  message="$2"
  default="$3"
  hidden="$4"

  ans=
  if [[ "$default" ]]
  then
    message="$message [$default]"
    if [[ "$OVERRIDE" ]]
    then
      ans="$default"
    fi
  fi

  while [[ ! "$ans" ]]
  do
    echo -ne "\n\n$message> "
    if [[ "$hidden" ]]
    then
      read -s ans
    else
      read ans
    fi
    if [[ "$ans" ]]
    then
      break
    elif [[ "$default" ]]
    then
      ans="$default"
      break
    fi
  done
  #
  eval "$varname=\"$ans\""
}

#------------------------------------ MAIN ------------------------------------

RESTART=.tmp.pipeline

if [[ ! -d .venv || ! -d app ]]
then
  fatal "This must be run in  root of APP folder"
fi

clear
echo
echo "[----------------------------------------------------------------"
echo "[ Running Postgres Database dump on test/local env"
echo "[----------------------------------------------------------------"
echo

ask REPLY "Do you want to dump the local database" N
REPLY=`echo ${REPLY} | tr "[a-z]" "[A-Z]"`
if [[ "${REPLY}" != "Y"  ]]
then
  fatal "Script abandoned"
fi

pg_dump -h localhost -U $USER -d ${DB}  | gzip > dump.${DB}.sql.gz

echo
echo "[ dump.sh -- ends OK ]"
