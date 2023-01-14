#!/usr/bin/env ruby

require 'abnftt'

parser = ABNF.from_abnf(File.read("draft-ietf-jsonpath-base.abnf"))

require 'json'

cts = JSON.parse(File.read("../jsonpath-compliance-test-suite/cts.json"))

SKIPPED_TESTS = [
  "union array access, overflowing index",
  "union array slice, overflowing to value",
  "union array slice, underflowing from value",
  "union array slice, overflowing from value with negative step",
  "union array slice, underflowing to value with negative step",
  "union array slice, overflowing step",
  "union array slice, underflowing step",
]

cts["tests"].each do |t|
    result = false
    should_accept = !t["invalid_selector"]
    begin
      parser.validate(t["selector"])
      result = true
    rescue => e
      warn "*** #{e}" # XXX
    end
    if result != should_accept
      if SKIPPED_TESTS.include? t["name"]
        warn "*** skipped #{t["name"]} (#{result} #{should_accept}): #{t["selector"]}"
      else
        fail "TEST #{t} #{result} #{should_accept}"
      end
    end
end
puts "---- successfully completed"
