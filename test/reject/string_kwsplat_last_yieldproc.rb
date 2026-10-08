# The final splat supplies the String variable that would be copied.
# spinel: reject-share
# spinel: reject-last-keyword
def m(k:) = k << "x"
def run(s, &b) = yield(k: +"other", **{ k: s })
s = +"s"
p run(s, &method(:m))
p s
