# A BasicObject.new is no Object and no Kernel to `when`, `in`, `===` and
# `grep`, and is a BasicObject, as in CRuby.
b = BasicObject.new
p(case b; when Object then :obj; when Kernel then :k; else :other; end)
p [Object === b, Kernel === b, BasicObject === b]
p(case b; when BasicObject then :bo; else :other; end)
p(case b; in Object then :obj; in BasicObject then :bo; end)
p [b, 1, "s"].grep(Object).size
x = [b, 1][0]
p [Object === x, BasicObject === x]
p [Object.new, b, 3].count { |v| Object === v }
