# A String variable on this route must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
s = +"a"
{k: s}.each { |k, q| f = -> { q << "!" }; f.call }
p s
