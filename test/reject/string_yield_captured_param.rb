# A String variable on this route must not silently lose its append.
# spinel: reject-share
# spinel: reject-captured-yield
def y(v) = yield(v)
s = +"a"
y(s) { |q| f = -> { q << "!" }; f.call }
p s
