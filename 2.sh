#!/bin/sh

cat << '%'

Now we set up a postgres database on p1. Postgres data lives
in a filesystem in the pool named postgres. The ZFS manual
encourages liberal use of filesystems because they are cheap
and are the main unit for making snapshots, etc.

%

set -x

sudo zfs create p1/postgres
sudo chown -R jra /p1/postgres

ctl=/usr/lib/postgresql/9.4/bin/pg_ctl

$ctl -D /p1/postgres init
mkdir p1.sock
pwd=`pwd`
$ctl -D /p1/postgres -l p1.log start -o "-h '' -k $pwd/p1.sock"
sleep 2

echo "ALTER SYSTEM SET wal_level = 'archive';" | \
	psql -h $pwd/p1.sock postgres

# restart it to pick up wal_level change
$ctl -D /p1/postgres -l p1.log stop -o "-h '' -k $pwd/p1.sock"
$ctl -D /p1/postgres -l p1.log start -o "-h '' -k $pwd/p1.sock"
sleep 2
