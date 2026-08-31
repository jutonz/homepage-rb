# typed: true

# `bin/ci` assigns this constant before requiring config/ci.rb:
#
#   CI = ActiveSupport::ContinuousIntegration
#
# Sorbet never reads bin/ci because it has no .rb extension, so the
# alias has to be declared here for config/ci.rb to resolve.
CI = ActiveSupport::ContinuousIntegration
