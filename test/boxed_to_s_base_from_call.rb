def base16
  scratch = Array.new(40) { |i| "x" * (i + 1) }
  scratch.size > 0 ? 16 : 10
end

vals = [2**70 + 5, nil, "s"]
out = []
30.times { |i| out << [vals[0] + i, nil][0].to_s(base16) }
p out.last
p [2**72, 1][0].inspect(base16)
p ["ff", 1][0].to_i(base16)
