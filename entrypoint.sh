#!/bin/bash

set -x

# do not proceed if the keyfile does not exist
if [[ ! -f /var/run/secrets/tarsnap ]]
then
  echo "Tarsnap keyfile could not be found! Are you sure it's placed in /var/run/secrets/tarsnap?"
  exit 1
fi

key_permissions=$(tarsnap-keymgmt --print-key-permissions /var/run/secrets/tarsnap)

# make sure we have write permissions
if [[ -z "$(echo $key_permissions | grep writing)" ]] ; then
  echo "The provided Tarsnap keyfile does not have write permissions - cannot continue!"
  exit 1
fi

# run tarsnap fsck if the cache is empty
if [ -z "$(ls -A /cache)" ]; then
  # make sure we have read permissions before running fsck
  if [[ -z "$(echo $key_permissions | grep reading)" ]] ; then
     tarsnap --keyfile /var/run/secrets/tarsnap --cachedir /cache --fsck
  fi
fi

set -e

# set timezone information
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
echo $TZ > /etc/timezone

# set crontab and run cron
crontab /var/run/crontab
cron -f
