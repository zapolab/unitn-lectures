#!/bin/bash
set -e

nohup opencode serve --hostname 0.0.0.0 --port 4000 > /tmp/opencode.log 2>&1 &

exec "$@"
