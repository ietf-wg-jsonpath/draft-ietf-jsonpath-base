#!/usr/bin/env ruby
require 'rexml/document'        # for SVG and bibxml acrobatics
require 'open3'                 # for math
require 'json'
require 'yaml'

# Check values against executing normalized paths on the JSON in tables
#
# Use kdrfc -c and run this on the v2v3.xml:
# ruby scripts/soco.rb draft-ietf-jsonpath-base.v2v3.xml | diff - soco.out

d = REXML::Document.new(ARGF)

def segfromnjp(s)
  scan = s.scan(/([$@])|\['((?:[^']|[\\]')*)'\]|([0-9]+)/)
  scan0 = scan.shift
  fail "*** SCAN0 #{scan0.inspect}" unless scan0 == ["$", nil, nil]
  scan.map {|root, key, ix|
    fail "*** LATE ROOT" if root
    [key && key.gsub("\\'", "'"), ix && ix.to_i]
  }
end

def seginterpret(v, segs)
  segs.each do |seg|
    case [v, *seg]
    in Hash, String => ky, nil
      v = v[ky]
    in Array, nil, Integer => ix
      v = v[ix]
    else      
      fail [:INTERPRET, v, seg].inspect
    end
  end
  v
end

jsontext = nil
jsondata = nil

        REXML::XPath.each(d.root, "//*[self::sourcecode or self::artwork or self::table]") do |x|
          puts
          # print x.name
          # p x.attributes
          # p x.text[0..20]
          case x.name
          when "table"
            if jsontext
              puts "--- Checking values against normalized paths in: #{jsontext}"
              doneanything = false
              next if Hash === jsondata && jsondata["obj"] # don't handle comparisons yet
              REXML::XPath.each(x, ".//tr") do |row|
                cells = REXML::XPath.each(row, ".//td").map {|cell|
                  REXML::XPath.each(cell, ".//tt").map{|x|x.text}
                }
                next if cells == []
                # p cells
                puts "*** too many cells" if cells.length > 4
                next if cells.length < 3
                qu, vals, paths, comments = cells
                puts "*** DIM" if vals.length != paths.length
                vals.zip(paths).each do |v, njp|
                  vj = JSON.load(v)
                  seg = segfromnjp(njp)
                  intp = seginterpret(jsondata, seg)
                  # puts [:SEGFROM, vj, intp, seg].inspect
                  fail [:MISMATCH, vj, intp].inspect if vj != intp
                  doneanything = true
                end
              end
              puts "... not done anything." unless doneanything
            else
              puts "=== no JSON for #{x.to_s[0..70]}."
            end
            jsontext = nil
          when "sourcecode"
            case x[:type]
            when "json"
              jsontext = jsontext
              jsontext = x.text
              jsondata = JSON.load(jsontext)
              puts jsondata.to_yaml
            end
          else
            puts "*** DIDNT EXPECT #{x.name}"
          end
        end
