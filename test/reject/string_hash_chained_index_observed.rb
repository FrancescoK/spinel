# A chained Hash value iterator currently mutates a copy. Refuse when the
# Hash can be observed after the block instead of silently losing the append.
# spinel: reject-share
h = { k: +"a" }
h.each_value.with_index { |q, i| q << "!" }
p h
