#!/bin/sh

cat << '%'
Now let's do a snapshot under load. We will concurrently
insert 1000 rows into the test table and take a snapshot.
We expect that when we bring up the database on p2, it will
come up cleanly, and have some rows (but not 1000) in it. 

%

pwd=`pwd`
psql="psql -h $pwd/p1.sock postgres"

(
	echo "updater started"
	date
	for i in `seq 1000`
	do
		echo "insert into test ( test ) values ( 'test $i' );"
	done | $psql -q
	echo "updater finished"
	date
)&

set -x

# inserts take 15 seconds on my machine, so sleep 4 means we
# get the first 20% or so of them.
sleep 4

echo "select pg_start_backup('2');" | $psql
sudo zfs snapshot p1/postgres@2
echo "select pg_stop_backup();" | $psql

sudo sh -c "zfs send -i p1/postgres@1 p1/postgres@2 | zfs recv p2/postgres@2"

wait
