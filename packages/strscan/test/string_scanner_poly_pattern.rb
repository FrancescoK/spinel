# A pattern that is a String at one call and a Regexp at another (a boxed
# argument) reaches the binding its class names at run time: a Regexp
# matches as a pattern, a String literally, and anything else is CRuby's
# TypeError.
require 'strscan'

s = StringScanner.new('<x>.y')
['<', /x/, '>', /./, '.'].each { |pt| p s.scan(pt) }
p s.pos

t = StringScanner.new('a1b2')
pats = [/a/, '1', /b/]
p pats.map { |pt| t.check(pt) }
p pats.map { |pt| t.skip(pt) }
p t.pos

u = StringScanner.new('key=value; rest')
[';', /=/].each { |pt| p u.scan_until(pt), u.matched }
p u.exist?(['r', /s/].first)

begin
  [1, /z/].each { |pt| s.scan(pt) }
rescue TypeError => e
  puts e.message
end
