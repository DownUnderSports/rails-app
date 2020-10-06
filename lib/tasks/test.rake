# encoding: utf-8
# frozen_string_literal: true

namespace :test do
  task js: [ :environment ] do |t|
    args = []
    begin
      idx = ARGV.find_index(t.name)
      if idx
        idx += 1
        idx += 1 if ARGV[idx] == "--"
        while ARGV.size > idx
          break if (ARGV[idx] !~ /--[a-z]+/) && (args.empty? || (ARGV[idx - 1] !~ /--[a-z]+/))
          args << ARGV[idx]
          idx += 1
        end
      end
    rescue
      args = []
    end
    args = args.present? ? " #{args.join(" ")}" : ""
    system "yarn test#{args}"
  end
end
