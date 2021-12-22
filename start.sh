#!/bin/bash

# Start the first process
./entrypoint.sh &

# Start the second process
/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?