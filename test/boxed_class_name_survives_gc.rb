# A class held as a value in an Array keeps its name across collections: an
# exception's class and a Method's owner are named by a fresh string that
# only the boxed class value holds.
class Probe
  def hi = 1
end

held = []
[TypeError, NoMethodError, ArgumentError, KeyError, ZeroDivisionError].each do |k|
  begin
    raise k, "boom"
  rescue => e
    held << [e.class, "x" * 40]
  end
end
m = Probe.new.method(:hi)
held << [m.owner, "y" * 40]
200.times { |i| "pad#{i}" * 3 }
held.each { |c, s| p [c, s.size] }
p held.map { |c, _| c.to_s }
