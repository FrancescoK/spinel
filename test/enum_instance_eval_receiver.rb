# detect and collect_concat written without a receiver in an instance_eval
# block call the block's receiver, an Array or a Hash here, which has the
# Enumerable methods; no reader of the program's is involved.
r = [[1], [2]].instance_eval { collect_concat { |v| v } }
p r
h = {a: [1]}.instance_eval { collect_concat { |k, v| v } }
p h
d = [3, 1].instance_eval { detect { |v| v < 3 } }
p d
