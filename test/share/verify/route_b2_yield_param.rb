class K; def run(v) = yield(v); end
$h = nil
s = +"abc"
K.new.run(s) { |x| $h = x }
($h) << "?"
p s
p($h)
