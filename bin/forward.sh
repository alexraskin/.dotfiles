#!/usr/bin/env bash

PORT="${1:-3000}"
echo "Forwarding port $PORT to localhost:$PORT"
ssh alex@morpheus -N -L "$PORT":localhost:"$PORT"
