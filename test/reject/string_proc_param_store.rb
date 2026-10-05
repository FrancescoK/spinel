# A proc stores its parameter's String into the Array, and the element is
# then appended to. No element iterator binds a proc's parameter, so the
# element would stay a copy: refused, not compiled with ["a", 2].
kept = []
blk = proc { |i, v| kept[i] = v }
blk.call(0, +"a")
blk.call(1, 2)
kept[0] << "b"
p kept
