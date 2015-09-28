#!/bin/sh

cat << '%'

Now we make a table in the database for testing. We will
make adds and updates to this table while checking that
no transactions are lost.

%

set -x
echo "create table test ( id serial, test varchar(80)); \d+ test;" | \
	psql -h `pwd`/p1.sock postgres
