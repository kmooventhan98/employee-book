ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Remove stale server.pid on boot to prevent server startup failure
pid_file = File.expand_path("../tmp/pids/server.pid", __dir__)
File.delete(pid_file) if File.exist?(pid_file)
