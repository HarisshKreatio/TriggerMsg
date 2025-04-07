#!/bin/bash

echo "Entry point script is being executed"

# Stops the execution of a script in case of error
set -e

# Remove a pre-existing server.pid
rm -f /tmp/trigger/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
