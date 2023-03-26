#!/usr/bin/env ruby

# $ gem install abnftt
require 'abnftt'

parser = ABNF.from_abnf(File.read("draft-ietf-jsonpath-base.abnf"))

require 'json'
# cts = JSON.parse(File.read("../jsonpath-compliance-test-suite/cts.json"))

# $ gem install open-uri-cached
require 'open-uri/cached'
# remove /tmp/open-uri... to clear cache

cts = JSON.parse(URI.open("https://raw.githubusercontent.com/jsonpath-standard/jsonpath-compliance-test-suite/main/cts.json").read)

# cts["tests"].map{_1["name"]}.grep /erflowing/

SKIPPED_TESTS = [
  "union array access, overflowing index",
  "union array slice, overflowing to value",
  "union array slice, underflowing from value",
  "union array slice, overflowing from value with negative step",
  "union array slice, underflowing to value with negative step",
  "union array slice, overflowing step",
  "union array slice, underflowing step",
  "index selector, overflowing index",
  "slice selector, overflowing to value",
  "slice selector, underflowing from value",
  "slice selector, overflowing from value with negative step",
  "slice selector, underflowing to value with negative step",
  "slice selector, overflowing step",
  "slice selector, underflowing step",
  # not tested by syntax:
  "filter, length function, result must be compared", # "selector"=>"$[?length(@.a)]"
  "filter, length function, no params", # "selector"=>"$[?length()==1]"
  "filter, length function, too many params", # "selector"=>"$[?length(@.a,@.b)==1]"
  "filter, count function, non-array/string arg", # "selector"=>"$[?count(1)>2]"
  "filter, count function, result must be compared", # "selector"=>"$[?count(@..*)]"
  "filter, count function, no params", # "selector"=>"$[?count()==1]"
  "filter, count function, too many params", # "selector"=>"$[?count(@.a,@.b)==1]"
  "filter, match function, result cannot be compared", # "selector"=>"$[?match(@.a, 'a.*')==true]"
  "filter, match function, too few params", # "selector"=>"$[?match(@.a)==1]"
  "filter, match function, too many params", # "selector"=>"$[?match(@.a,@.b,@.c)==1]"
  "filter, search function, result cannot be compared", # "selector"=>"$[?search(@.a, 'a.*')==true]"
  "filter, search function, too few params", # "selector"=>"$[?search(@.a)]"
  "filter, search function, too many params", # "selector"=>"$[?search(@.a,@.b,@.c)]"
  "filter, value function, too few params", # "selector"=>"$[?value()==4]"
  "filter, value function, too many params", # "selector"=>"$[?value(@.a,@.b)==4]"
  "filter, value function, result must be compared", # "selector"=>"$[?value(@.a)]"
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
        warn "TEST #{t} #{result} #{should_accept}"
      end
    end
end
puts "---- successfully completed"
