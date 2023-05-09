#!/usr/bin/env bash

set -o xtrace
set -o errexit

# Initial setup
mix deps.get --only prod
MIX_ENV=prod mix compile

# Compile assets
yarn  --cwd ./assets install
yarn  --cwd ./assets run build

mix phx.digest

# Build the release and overwrite the existing release directory
MIX_ENV=prod mix release --overwrite
