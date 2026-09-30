# `x[k] = v` on a boxed Hash or OpenStruct (one read out of a mixed value).
# The value is boxed before the key runs, and a computed key allocates, so
# the value has to be rooted: a collection there left garbage in the entry.
# A boxed OpenStruct also takes a String key, which was dropped on the write
# and answered nil on the read.
require "ostruct"

def fill(x, i, sym)
  300.times { |j| sym ? x[:"m#{j}"] = "v#{i}_#{j}" : x["m#{j}"] = "v#{i}_#{j}" }
  x
end

def mixed_key(x, i)
  300.times { |j| k = j.even? ? :"m#{j}" : "m#{j}"; x[k] = "v#{i}_#{j}" }
  x
end

[[{}, :hash], [OpenStruct.new, :ostruct]].each do |proto, kind|
  [true, false].each do |sym|
    bad = 0
    20.times do |i|
      x = fill([proto.dup, 0][0], i, sym)
      bad += (0...300).count { |j| x[sym ? :"m#{j}" : "m#{j}"] != "v#{i}_#{j}" }
    end
    p [kind, sym, bad]
  end
end

bad = 0
20.times do |i|
  x = mixed_key([OpenStruct.new, 0][0], i)
  bad += (0...300).count { |j| x[:"m#{j}"] != "v#{i}_#{j}" }
end
p [:ostruct_mixed_key, bad]

o = [OpenStruct.new, 0][0]
o["name"] = "s"
o[:size] = 3
p o, o["name"], o[:size]
begin
  k = [1, :a][0]
  o[k] = 2
rescue NoMethodError => e
  p e.message
end
