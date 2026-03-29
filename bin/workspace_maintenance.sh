#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

mise exec -- bundle install
RAILS_ENV=test mise exec -- bin/rails db:prepare assets:precompile
