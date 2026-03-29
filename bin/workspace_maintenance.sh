#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

bundle install
RAILS_ENV=test bin/rails db:prepare
RAILS_ENV=test mise exec -- bin/rails assets:precompile
