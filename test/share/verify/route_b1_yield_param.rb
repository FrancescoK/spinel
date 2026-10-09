class K; def run(v) = yield(v); end
$h = nil
s = +"abc"
K.new.run(s) { |x| $h = x }
s << "!"
p($h)
p s
