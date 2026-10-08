# The exception being handled and the message being raised are each reachable
# from nothing but a C local for one allocation: the object between the landing
# that materializes it and the push that roots it, the message between the
# raiser that formats it and the slot the marker reads. Every pin below raises
# after enough allocation for a collection to land in one of those windows.
# spinel: wasm
# an unspecialized `rescue => e` arm, on a raise that carries no object
pad = Array.new(64) { |i| (10 ** 20) + i }
q = pad.map { |x| x.to_s.length }
begin
  raise TypeError, "coerce must return [x, y]"
rescue => e
  p [e.class, e.message, e.backtrace.class]
  p $!.equal?(e)
end
p q.sum

# a specialized arm -- one arm, one user subclass -- which the landing
# materializes through a differently sized allocation
class Refused < StandardError
end
begin
  raise Refused, "no such rate"
rescue Refused => e
  p [e.class, e.message, e.backtrace.class]
  p $!.equal?(e)
end

# a runtime-formatted message: the raiser builds the text itself, so what it
# hands over is a heap string, not a literal
churn = []
box = [Complex(3, 4)]
8.times do |i|
  churn << "s#{i}" * 3
  begin
    box[0].div(2)
  rescue => e
    p [e.class, e.message]
  end
end
p churn.size

# a formatted message the raise path also reads back, to recover #name onto
# the carried exception
begin
  Object.const_get("NoSuchRateTable")
rescue NameError => e
  p [e.class, e.message]
end

# Each window is one allocation wide, so it opens only when a collection lands
# inside it. Raising this many times against a heap that keeps growing puts a
# natural collection there without SPINEL_GC_STRESS: this answers
# [RuntimeError, ""] a handful of times per 20000 rounds when the handled
# exception is not rooted.
bad = 0
keep = []
20000.times do |i|
  keep << [i] if i % 100 == 0
  begin
    raise TypeError, "coerce must return [x, y]"
  rescue => e
    unless e.class == TypeError && e.message == "coerce must return [x, y]" && e.backtrace.class == Array
      bad += 1
      p [i, e.class, e.message] if bad < 4
    end
  end
end
p [bad, keep.size]
