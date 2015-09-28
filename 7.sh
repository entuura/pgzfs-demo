#!/bin/sh

cat << '%'
Let's simulate the loss of the primary Postgres hardware.
It would take too long to go to the DC and move the disks into
the seconadry hardware. So we'll just have to accept a bit of
data loss between the last snapshot and now. We will make
the p2/postgres@2 snapshot the new master, and start Postgres on it.

%

pwd=`pwd`
p1sql="psql -h $pwd/p1.sock postgres"
p2sql="psql -h $pwd/p2.sock postgres"
ctl=/usr/lib/postgresql/9.4/bin/pg_ctl

set -x

echo "p1 has this many records in table test:"
echo "select max(id) from test;" | $p1sql
# and kill it dead.
$ctl -D /p1/postgres -l p1.log stop

sudo zfs clone p2/postgres@2 p2/postgres_2
sudo zfs promote p2/postgres_2
sudo zfs rename p2/postgres p2/postgres_
sudo zfs rename p2/postgres_2 p2/postgres
sudo zfs destroy p2/postgres_

# The snapshot is a little too good; we need to remove the
# PID file because we are now authoratative for this directory,
# even though the PID file from the other postmaster is still here.
rm /p2/postgres/postmaster.pid

mkdir p2.sock
$ctl -D /p2/postgres -l p2.log start -o "-h '' -k $pwd/p2.sock"
sleep 2

echo "The p2.log file shows that this is an unclean startup:"
cat p2.log

echo
echo "p2 has this many records in table test:"
echo "select max(id) from test;" | $p2sql

echo "p2 has fewer records than p1 had because it was recovered"
echo "from a snapshot taken on a server under load. In production,"
echo "we can take and send snapshots as often as we want, even in a"
echo "continual loop, assuming we have the right scripts in place to"
echo "prune snapshots."
