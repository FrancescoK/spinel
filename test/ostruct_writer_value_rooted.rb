# A value written to an OpenStruct member stays reachable while the member's
# name is looked up (a name built at run time is interned first).
require "ostruct"

# `o[:name] = v`, the name built at run time
def big(i)
  o = OpenStruct.new
  300.times { |j| o[:"m#{j}"] = "v#{i}_#{j}" }
  o
end
bad = 0
60.times { |i| o = big(i); bad += (0...300).count { |j| o[:"m#{j}"] != "v#{i}_#{j}" } }
p bad

# `o.name = v`, the names in the source
o = OpenStruct.new(a: 1)
o.m0000 = "a" * 5
o.m0001 = "a" * 5
o.m0002 = "a" * 5
o.m0003 = "a" * 5
o.m0004 = "a" * 5
o.m0005 = "a" * 5
o.m0006 = "a" * 5
o.m0007 = "a" * 5
o.m0008 = "a" * 5
o.m0009 = "a" * 5
o.m0010 = "a" * 5
o.m0011 = "a" * 5
o.m0012 = "a" * 5
o.m0013 = "a" * 5
o.m0014 = "a" * 5
o.m0015 = "a" * 5
o.m0016 = "a" * 5
o.m0017 = "a" * 5
o.m0018 = "a" * 5
o.m0019 = "a" * 5
o.m0020 = "a" * 5
o.m0021 = "a" * 5
o.m0022 = "a" * 5
o.m0023 = "a" * 5
o.m0024 = "a" * 5
o.m0025 = "a" * 5
o.m0026 = "a" * 5
o.m0027 = "a" * 5
o.m0028 = "a" * 5
o.m0029 = "a" * 5
o.m0030 = "a" * 5
o.m0031 = "a" * 5
o.m0032 = "a" * 5
o.m0033 = "a" * 5
o.m0034 = "a" * 5
o.m0035 = "a" * 5
o.m0036 = "a" * 5
o.m0037 = "a" * 5
o.m0038 = "a" * 5
o.m0039 = "a" * 5
p o.to_h.size
p o.to_h.reject { |k, v| k == :a || v == "aaaaa" }.size
