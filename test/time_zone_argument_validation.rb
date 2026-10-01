# A zone argument -- `in:`, Time.new's 7th positional, localtime / getlocal --
# is read the way CRuby reads it: the offset fields are range-checked, a
# military letter is a whole-hour offset, a negative zero and "UTC" are UTC,
# and a whole-second Float or Rational is an offset.
def at_in(z)
  t = Time.at(0, in: z)
  [t.utc_offset, t.utc?, t.zone]
rescue => e
  [e.class, e.message]
end

%w[UTC utc Z -00:00 -0000 -00 +00:00 +09 +0900 +090000 +09:00:00 +23:59:59 -23:59:59
   A I K M N Y +09:99 +09:60 +23:59:60 +24:00 +2400 +99 -24:00 J GMT z a +9 +09:0 +0900:00
   09:00].each { |z| p [z, at_in(z)] }
[3600, -3600, 86399, 86400, -86400, 3600r, 7200.0, -1800.0].each { |z| p [z, at_in(z)] }
zs = [:x, "+05:30", 3600, nil, 2.0]
zs.each do |z|
  r = at_in(z)
  r = :local if z.nil? && r == [Time.at(0).utc_offset, false, Time.at(0).zone]
  p [z, r]
end

def tm(m, z)
  t = Time.at(0).send(m, z)
  [t.utc_offset, t.utc?, t.zone]
rescue => e
  [e.class, e.message]
end
%w[UTC Z -00:00 +00:00 A +0900 +09:99 +24:00 J GMT].each do |z|
  p [z, tm(:localtime, z), tm(:getlocal, z)]
end
[3600, 86400, -86400, 3600r].each { |z| p [z, tm(:localtime, z), tm(:getlocal, z)] }
t = Time.at(0)
t.localtime("UTC")
p t.utc?, t.zone
u = [Time.at(0), 1][0]
p u.localtime("-00:00").utc?, u.getlocal("K").utc_offset, u.getlocal([3600r, 1][0]).utc_offset
p((u.getlocal("+09:99") rescue $!.message))
lt = u.getlocal(nil)
p lt.utc_offset == Time.at(0).utc_offset

def nw(z)
  t = Time.new(2000, 1, 1, 0, 0, 0, z)
  [t.to_i, t.utc_offset, t.utc?]
rescue => e
  [e.class, e.message]
end
%w[UTC -00:00 A +09:99 +24:00 J].each { |z| p [z, nw(z)] }
[3600, 3600r, [7200, 1][0], :x].each { |z| p [z, nw(z)] }
p nw([nil, 1][0]) == [Time.new(2000, 1, 1).to_i, Time.new(2000, 1, 1).utc_offset, false]
p((Time.now(in: "+09:99") rescue $!.message))
p Time.now(in: "-00:00").utc?
order = []
log = ->(x) { order << x; x }
Time.new(log.(2000), log.(1), log.(1), log.(0), log.(0), log.(0), log.("+01:00"))
p order
