#!/bin/sh

set -x

ctl=/usr/lib/postgresql/9.4/bin/pg_ctl
$ctl -D /p1/postgres stop
$ctl -D /p2/postgres stop

sudo zpool destroy p1
sudo zpool destroy p2

rm -f p[12]-[123]
rm -rf p1.log p2.log p1.sock p2.sock
