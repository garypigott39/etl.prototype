#!/bin/bash

#------------------------------------------------------------------------------
# @file: restore.sh
#
# Restore database dump locally. It is expected to be run via CLI.
#
# Called as:
#
#   restore.sh
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
echo "[ Running Postgres Database restore on test/local env"
echo "[----------------------------------------------------------------"
echo

ask REPLY "Do you want to restore the local database" N
REPLY=`echo ${REPLY} | tr "[a-z]" "[A-Z]"`
if [[ "${REPLY}" != "Y"  ]]
then
  fatal "Script abandoned"
elif [[ ! -s dump.${DB}.sql.gz ]]
then
  fatal "Database dump file 'dump.${DB}.sql.gz' not found"
fi

dropdb -U $USER -h localhost --if-exists ${DB}
if [[ $? -ne 0 ]]
then
  fatal "Unable to drop ${DB} database"
fi

createdb -U $USER -h localhost ${DB}
if [[ $? -ne 0 ]]
then
  fatal "Unable to create ${DB} database"
fi

gunzip -c dump.${DB}.sql.gz | psql -h localhost -U $USER -d ${DB}

# Change timezone to UTC
psql -h localhost -U $USER -d ${DB} -c "ALTER DATABASE ${DB} SET TIME ZONE 'UTC'"

echo
echo "******************************************************************************"
echo "Check out the Database init/schema SQL files in the database sql folders"
echo "for any other actions... e.g. create EXTENSIONS etc."
echo "******************************************************************************"
echo

echo
echo "[ restore.sh -- ends OK ]"
