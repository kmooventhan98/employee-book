ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

# Remove stale server.pid on boot to prevent server startup failure
pid_file = File.expand_path("../tmp/pids/server.pid", __dir__)
File.delete(pid_file) if File.exist?(pid_file)

# Automatically load .env if present
env_file = File.expand_path("../.env", __dir__)
if File.exist?(env_file)
  File.foreach(env_file) do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")
    key, val = line.split("=", 2)
    ENV[key.strip] ||= val.to_s.strip.gsub(/\A["']|["']\z/, "") if key
  end
end
