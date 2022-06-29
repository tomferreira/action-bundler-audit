#!/usr/bin/env ruby
require 'json'

GEMFILE_LOCK_PATH = "Gemfile.lock"

CRITICALITY_RANK = {
  none: 0,
  low: 1,
  medium: 2,
  high: 3,
  critical: 3,
}

SEVERITY = ["UNKNOWN_SEVERITY", "INFO", "WARNING", "ERROR"]

input_json = JSON.parse(ARGF.read)

max_criticality_rank = 0
results = input_json["results"]

diagnostics = results.map do |result|
  gem_name =  result.dig("gem", "name")

  message = <<~EOS
    Title: #{result.dig("advisory", "title")}
    Solution: upgrade to #{result.dig("advisory", "patched_versions").map{|v| "'#{v}'"}.join(', ')}
  EOS

  criticality_rank = CRITICALITY_RANK[result.dig("advisory", "criticality").to_sym]
  max_criticality_rank = [max_criticality_rank, criticality_rank].max 

  line = `grep -n -E '^\s{2}#{gem_name}' #{GEMFILE_LOCK_PATH} | cut -d : -f 1`.to_i

  diagnostic = {
    message: message,
    location: {
      path: GEMFILE_LOCK_PATH,
      range: {
        start: {
          line: line,
          column: 0
        }
      }
    },
    severity: SEVERITY[criticality_rank],
    code: {
      value: result.dig("advisory", "id"),
      url: result.dig("advisory", "url")
    }
  }
end

result = {
  source: {
    name: "bundler-audit",
    url: "https://github.com/rubysec/bundler-audit"
  },
  severity: SEVERITY[max_criticality_rank],
  diagnostics: diagnostics
}

puts result.to_json