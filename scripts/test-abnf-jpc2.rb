#!/usr/bin/env ruby

# $ gem install abnftt
require 'abnftt'

parser = ABNF.from_abnf(File.read("draft-ietf-jsonpath-base.abnf"))

require 'json'

require 'open-uri/cached'
require 'yaml'

tests = YAML.load(URI("https://raw.githubusercontent.com/cburgmer/json-path-comparison/master/INTERESTING_QUERIES").open.read)

FAILING_CORRECTLY = [
 "$...key",
 "$[?(42)]",
 "$[?(!!@.key)]", # !!! not robust against missing parens
 "$[?((@.key)==42)", # not robust against superfluous parens
 "$[?((@.key==42))", # not robust against superfluous parens
 # no arrays:
 "$[?([1,2]<[3,4])]",
 "$[?(@.key<[3,4])]",
]

success = true
tests.each do |t|
  sel = t["selector"]
  puts sel
  result = false
  begin
    parser.validate(sel)
    if FAILING_CORRECTLY.include?(sel)
      warn "*** NOT FAILING #{sel}" 
      success = false
    end
    warn "OK: #{sel}"
    result = true
  rescue => e
    wt = if FAILING_CORRECTLY.include?(sel)
           "OK -- failing correctly:"
         else
           success = false
           "*** FAIL"
         end
    warn "#{wt} #{sel} #{e}" # XXX
  end
end
puts "---- successfully completed" if success
