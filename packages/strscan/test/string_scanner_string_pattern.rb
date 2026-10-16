# A String pattern matches its text literally: scan / check / match? / skip
# at the scan pointer, the _until forms and exist? anywhere ahead, with the
# same match state a Regexp leaves (matched, pre_match, [0], unscan).
require 'strscan'

s = StringScanner.new('&lt;x&gt;y.z')
p s.scan('&lt;'), s.pos, s.matched, s.pre_match, s.post_match, s[0]
p s.scan('&gt;'), s.pos, s.matched?
p s.check('x'), s.pos, s.matched
p s.match?('x&'), s.skip('x')
p s.scan_until('y'), s.pos, s.matched, s.pre_match
p s.check_until('z'), s.exist?('z'), s.skip_until('.'), s.pos
p s.scan(''), s.scan_until('nope'), s.pos
begin
  s.unscan
rescue StringScanner::Error => e
  puts e.message
end

# a String held in a variable, and a `.` that is not a wildcard
pat = '.'
p s.scan(pat), s.scan(/z/), s.eos?

t = StringScanner.new('été')
p t.scan('é'), t.pos, t.scan_until('é'), t.pos
