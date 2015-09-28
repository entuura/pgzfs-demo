#!/bin/sh

cat << '%'
Let's confirm that we can continue writing to our new master (p2)
and send these writes to p1.

%

pwd=`pwd`
p2sql="psql -h $pwd/p2.sock postgres"

echo "select max(id) from test;" | $p2sql

echo "updater started"
date
for i in `seq 100`
do
	echo "insert into test ( test ) values ( 'test $i' );"
done | $p2sql -q
echo "updater finished"
date

echo "select max(id) from test;" | $p2sql

set -x

echo "select pg_start_backup('3');" | $p2sql
sudo zfs snapshot p2/postgres@3
echo "select pg_stop_backup();" | $p2sql

# p1 is no longer the master, so we need to have a blank slate
# to receive new authoratative data from p2.
sudo zfs destroy -r p1/postgres

sudo sh -c "zfs send p2/postgres@3 | zfs recv p1/postgres"

cat << '%'
Now p2 and p1 are in precisely the same state p1 and p2 were
after running 4.sh. A failover to latest snapshot from p2 to p1
would follow the same steps as 7.sh.

%
