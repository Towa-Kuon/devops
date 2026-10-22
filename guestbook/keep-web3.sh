#!/bin/bash
cd "$(dirname "$0")"

while true; do
    count=$(docker compose ps --status running -q web | wc -l)
    if [ "$count" -ne 3 ]; then
        docker compose up -d --scale web=3
    fi
    sleep 5
done
