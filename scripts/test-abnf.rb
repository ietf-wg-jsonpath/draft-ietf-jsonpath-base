#!/usr/bin/env ruby

require 'abnftt'

parser = ABNF.from_abnf(File.read("draft-ietf-jsonpath-base.abnf"))

ACCEPT = {"+" => true, "-" => false}
s = DATA.read.split(/^#/)
s.each do |l|
  accept, *cases = l.split("\n")
  next unless accept
  fail "ACCEPT #{s.inspect} #{accept.inspect}" if (should_accept = ACCEPT[accept]).nil?
  puts "---- should_accept = #{should_accept}"
  cases.each do |thecase|
    p thecase
    result = false
    begin
      parser.validate(thecase)
      result = true
    rescue => e
      warn "*** #{e}" # XXX
    end
    fail "CASE #{thecase} #{result} #{should_accept}" if result != should_accept
  end
end
puts "---- successfully completed"

__END__

#+
$['foo']
$["foo"]
$.foo
$..['foo']
$..["foo"]
$[*]
$.*
$..*
$[:]
$[::]
$[::2]
$[:0:]
$[:0:2]
$[1:]
$[1::]
$[1::2]
$[1:0:]
$[1:0:2]
$["foo", 1, 83:-21:2]
$[0]
$[-3:-21:2, -6]
$[?@>=true]
$[?@.__B&&@[-3]||@>=true]

#-
nodollar
$...foo
$[:-0:]
$[-0]


#+
$
$.store.book[*].author
$..author
$.store.*
$.store..price
$..book[2]
$..book[-1]
$..book[0,1]
$..book[:2]
$..book[?(@.isbn)]
$..book[?(@.price<10)]
$..*
$
$.o['j j']['k.k']
$.o["j j"]["k.k"]
$["'"]["@"]
$[*]
$.o[*]
$.o[*]
$.o[*,*]
$.a[*]
$[1]
$[-2]
$[1:3]
$[1:5:2]
$[5:1:-2]
$[::-1]
$[?$.absent1 == $.absent2]
$[?$.absent1 <= $.absent2]
$[?$.absent == 'g']
$[?$.absent1 != $.absent2]
$[?$.absent != 'g']
$[?$.obj == $.arr]
$[?$.obj != $.arr]
$[?$.obj == $.obj]
$[?$.obj != $.obj]
$[?$.arr == $.arr]
$[?$.arr != $.arr]
$[?$.obj == 17]
$[?$.obj != 17]
$[?$.obj <= $.arr]
$[?$.obj < $.arr]
$[?$.obj <= $.obj]
$[?$.arr <= $.arr]
$[?$.a[?@.b == 'kilo']]
$.a[?@>3.5]
$.a[?@.b]
$[?@.*]
$[?@[?@.b]]
$.o[?@<3, ?@<3]
$.a[?@<2 || @.b == "k"]
$.a[?match(@.b,"[jk]")]
$.a[?search(@.b,"[jk]")]
$.o[?@>1 && @<4]
$.o[?@>1 && @<4]
$.o[?@.u || @.x]
$.a[?(@.b == $.x)]
$[?(@ == @)]
$[?length(@) < 3]
$[?length(@.*) < 3]
$[?count(@.*) == 1]
$[?count(1) == 1]
$[?count(foo(@.*)) == 1]
$[?match(@.timezone, 'Europe/.*')]
$[?match(@.timezone, 'Europe/.*') == true]
$[0, 3]
$[0:2, 5]
$[0, 0]
$..j
$..j
$..[0]
$..[0]
$..[*]
$..*
$..o
$.o..[*, *]
$.a..[0, 1]
$.a
$.a[0]
$.a.d
$.b[0]
$.b[*]
$.b[?@]
$.b[?@==null]
$.c[?(@.d==null)]
$.null
$.a
$[1]
$[-3]
$.a.b[1:2]
$["\u000B"]
$["\u0061"]
