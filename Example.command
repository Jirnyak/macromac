#!/bin/zsh
cd "$(dirname "$0")"
exec swift run macro -- --runner --play --macro example.json
