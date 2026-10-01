# A local that holds nil (or anything but a String) yielded into an inlined
# block that appends to its parameter: the method's parameter has no
# `const char *` slot to alias there (the local is boxed), so it binds the
# value as it is. Positionally, by keyword, and through two levels of yield
# this failed the C build. A String yielded the same way still shares the
# append (#6179).
def run(x) = yield(x)
u = nil
p run(u) { |w| w.nil? ? :n : (w << "!") }
s = +"a"; run(s) { |w| w << "!" }; p s

def yk(v) = yield(k1: v)
p yk(u) { |k1: nil| k1 && (k1 << "!") }
t = +"o"; yk(t) { |k1:| k1 << "!" }; p t

def run2(x) = run(x) { |q| yield q }
p run2(u) { |w| w.nil? ? :n : (w << "!") }
r = +"r"; run2(r) { |w| w << "?" }; p r
