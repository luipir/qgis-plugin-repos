#!/bin/bash
# An archive name can be specified on the command line,
# if not, a default name will be generated by appending
# date and time to "qgis-repo-www-backup_"
set -e

QGIS_BASE=qgisrepo_base_1
QGIS_ARCHIVE=$1

if [ -z "$QGIS_ARCHIVE" ]; then
  echo "No backup archive set as first paramter to script!"
  exit 1
fi

aregx='^/.*'

if ! [[ "${QGIS_ARCHIVE}" =~ $aregx ]]; then
  echo "Backup archive file path is not absolute!"
  exit 1
fi

if ! [ -f "${QGIS_ARCHIVE}" ]; then
  echo "Backup archive file not found or invalid file path!"
  exit 1
fi

fregx='^qgis-repo-www-backup_.*\.(tgz|tar\.gz)'

if ! [[ $(basename "${QGIS_ARCHIVE}") =~ ${fregx} ]]; then
  echo "Backup archive file name does not match expected pattern!"
  exit 1
fi


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo -e "\nApplying environment..."
. ${SCRIPT_DIR}/docker-compose.env

echo -e "\nAttempting to restore ${QGIS_BASE}'s www dir from ${QGIS_ARCHIVE}..."

gunzip --to-stdout "${QGIS_ARCHIVE}" | docker exec -i ${QGIS_BASE} tar -C / -xf - 
