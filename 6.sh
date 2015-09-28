#!/bin/sh

cat << '%'
Let's simulate the loss of a mirror due to disk corruption.
We do SQL before and after to show that Postgres is still up.

%

pwd=`pwd`
psql="psql -h $pwd/p1.sock postgres"

set -x

echo "Before the corruption:"
echo "select max(id) from test;" | $psql
sudo zpool status p1

# scribble random data into p1-1... aieee!
dd if=/dev/urandom of=p1-1 skip=1000 count=100 bs=8192

echo "After the corruption event:"
echo "select max(id) from test;" | $psql
sudo zpool status p1

echo "ZFS has not yet detected the error, because the read rate is too"
echo "low in this demo. Let's ask it to go look for damage."
echo

sudo zpool scrub p1

echo "With the scrub running:"
echo "select max(id) from test;" | $psql
sudo zpool status p1

cat << '%'
And now, let's fix the mirror. We create a new fake disk
and use "zpool replace" to substitute it into the mirror.
ZFS starts copying data onto the new disk file. The amount
of data is so small that it takes 0 seconds to do it.
(see line starting with "scan:")

%

dd if=/dev/zero of=p1-3 bs=1024 count=500000
sudo zpool replace p1 $pwd/p1-1 $pwd/p1-3
rm $pwd/p1-1
sleep 1
sudo zpool status p1

echo "After the mirror was fixed:"
echo "select max(id) from test;" | $psql
