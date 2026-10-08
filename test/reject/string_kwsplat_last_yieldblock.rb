# The final splat supplies the String variable that would be copied.
# spinel: reject-share
# spinel: reject-last-keyword
def run(s) = yield(k: +"other", **{ k: s })
s = +"s"
p run(s) { |k:| k << "x" }
p s
