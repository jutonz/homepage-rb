#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

npm i
npm exec --no playwright install --with-deps

bundle install
RAILS_ENV=test bin/rails db:prepare
