ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.

require "coerce_boolean"

Warning[:deprecated] = CoerceBoolean.from(ENV["ENABLE_RUBY_DEPRECATED"], strict: true)
Warning[:experimental] = CoerceBoolean.from(ENV["ENABLE_RUBY_EXPERIMENTAL"], strict: true)

# Require Pre-Initializer Core Extensions
Dir.glob("#{File.expand_path(__dir__)}/core_ext/*.rb").each do |d|
  require d
end
