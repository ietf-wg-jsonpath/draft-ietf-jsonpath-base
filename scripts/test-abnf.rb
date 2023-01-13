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

#-
nodollar
$...foo
$[:-0:]
