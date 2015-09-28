#!/bin/sh

cat << '%'

First we make two ZFS pools backed with regular files.

In production:
	* each of these files would be a full disk
	* pool p1 would be on the first postgres server
	* pool p2 would be on the second postgres server

p1 and p2 are not called "master" and "slave" because
we will demonstrate p1 replicates to p2, then p2 is master
(p1 is dead), then p2 replicates to p1.

%

if [ -f p1-1 ]; then
	echo "file1 exists, run 'sh reset.sh', if you are sure..."
	exit 1
fi

set -x

(
dd if=/dev/zero of=p1-1 bs=1024 count=500000
dd if=/dev/zero of=p1-2 bs=1024 count=500000
dd if=/dev/zero of=p2-1 bs=1024 count=500000
dd if=/dev/zero of=p2-2 bs=1024 count=500000

)2>/dev/null

p=`pwd`
sudo zpool create p1 mirror $p/p1-1 $p/p1-2
sudo zpool create p2 mirror $p/p2-1 $p/p2-2

sudo zpool status p1 p2
