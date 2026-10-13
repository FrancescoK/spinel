# spinel: share
# spinel: gc-minor
# ENV.update and merge! with a conflict block took a hash literal of any
# variant as a String => String hash and handed it to the runtime's
# StrStrHash entry, and a hash local of another variant, or a value that is
# not a hash, fell through to a NameError for ENV. A literal with a nil, Integer or Symbol member, an empty
# `{}`, and under --share-strings a String value that is a shared String (the
# literal's value variant follows a hash of the same shape that holds one),
# gave invalid C. Such a hash is now boxed as the blockless form takes it: a
# key already set yields key, old and new value, nil deletes, and a key, or a
# stored value, that is not a String raises CRuby's TypeError, as does a
# value that is not a hash. A Float the block replaces is handed to it as
# the Float, a huge one or Infinity included, without first being read as
# an Integer.
v = +"ab"
h = {"SPX_J" => v}
ENV.update(h)
v << "c"
p ENV["SPX_J"]
ENV.update({"SPX_J" => "z"}) { |*| "q" }
p ENV["SPX_J"]
ENV.merge!({"SPX_J" => "m", "SPX_K" => "k"}) { |k, o, n| "#{k}:#{o}:#{n}" }
p ENV["SPX_J"], ENV["SPX_K"]
pr = proc { |k, o, n| o * 2 }
ENV.update({"SPX_K" => "z"}, &pr)
p ENV["SPX_K"]
ENV.update({"SPX_J" => nil, "SPX_K" => "n"}) { |k, o, n| nil }
p ENV["SPX_J"], ENV["SPX_K"]
ENV["SPX_J"] = "a"
ENV.update({"SPX_J" => 1}) { |k, o, n| n.to_s + o }
p ENV["SPX_J"]
begin
  ENV.update({"SPX_J" => :z}) { |k, o, n| n }
rescue TypeError => e
  p e.message
end
p ENV["SPX_J"]
begin
  ENV.update({"SPX_L" => "l", 5 => "b"}) { |*| "q" }
rescue TypeError => e
  p e.message
end
p ENV["SPX_L"]
begin
  ENV.update({SPX_J: "z"}) { |*| "q" }
rescue TypeError => e
  p e.message
end
p ENV.update({}) { |*| "q" }["SPX_J"]
a = +"one"
g = {"SPX_M" => a}
ENV["SPX_M"] = "pre"
ENV.update(g) { |k, o, n| n.upcase + o }
a << "two"
p ENV["SPX_M"], g["SPX_M"]
o = {}
20.times { |i| o["SPX_N#{i}"] = "o#{i}" }
ENV.update(o)
w = {}
20.times { |i| w["SPX_N#{i}"] = "n#{i}" * 3 }
ENV.update(w) { |k, o, n| x = +o; x << n.reverse; x }
p ENV["SPX_N0"], ENV["SPX_N19"]
x = ARGV.size > 3 ? {"SPX_Y" => "a"} : nil
begin
  ENV.update(x) { |*| "q" }
rescue TypeError => e
  p e.message
end
begin
  ENV.merge!(5) { |*| "q" }
rescue TypeError => e
  p e.message
end
ENV["SPX_F"] = "a"
ENV["SPX_I"] = "b"
ENV.merge!({ "SPX_F" => 1e30, "SPX_I" => Float::INFINITY, "SPX_S" => "s" }) { |k, o, n| "#{k}:#{o}:#{n}" }
p ENV["SPX_F"], ENV["SPX_I"], ENV["SPX_S"]
