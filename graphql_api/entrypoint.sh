#!/bin/bash

echo "entrypoint.sh: Removing server.pid"
rm -f tmp/pids/server.pid
echo "entrypoint.sh: Running exec"
exec "$@"