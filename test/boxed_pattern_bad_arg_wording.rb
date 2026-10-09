# spinel: share
# spinel: gc-minor
# A pattern read out of a mixed Array that is neither a Regexp nor a String:
# split, partition and rpartition raise CRuby's "wrong argument type X
# (expected Regexp)". They said "no implicit conversion of X into String".
# nil is still split's whitespace mode, and an object with #to_str converts;
# one without it raises the same TypeError.

class Sep
  def to_str = "b"
end
class Pt; end
BAD = [1, 2.5, :sym, nil, true, 1..2, Sep.new, Pt.new, "b", /b/]
s = "abc d"
BAD.each do |pat|
  [-> { s.split(pat) }, -> { s.split(pat, 2) }, -> { s.partition(pat) },
   -> { s.rpartition(pat) }].each_with_index do |f, i|
    puts "#{pat.inspect[0, 4]} #{i}: #{f.call.inspect}"
  rescue TypeError => e
    puts "#{pat.inspect[0, 4]} #{i}: #{e.message}"
  end
end
