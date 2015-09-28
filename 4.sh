#!/bin/sh

cat << '%'

We snapshot the database and send it to p2. We tell Postgres that
a snapshot is happening so that it ensures tables are in a stable
state, and only the xlog files will be growing during the snapshot
(growing in an ACID-safe manner, that is).

If Postgres needs to be started on the secondary, it will discover
an unclean database, and do a recovery using the xlog files in the
snapshot.

%

pwd=`pwd`
psql="psql -h $pwd/p1.sock postgres"

set -x

echo "select pg_start_backup('1');" | $psql
sudo zfs snapshot p1/postgres@1
echo "select pg_stop_backup();" | $psql

sudo sh -c "zfs send p1/postgres@1 | zfs recv p2/postgres@1"
