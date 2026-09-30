# A yield passed as an argument to a method the program defines, from a
# method whose blocks answer different types at different call sites. The
# callee's parameter took the first site's type, so the other site's value
# was converted to it at run time: a String block, then a Float one, raised
# TypeError where CRuby prints both.

def show(v) = v.inspect
def pair(a, b) = [a, b].inspect

def shown = show(yield)
def paired = pair(yield, 1)

class Box
  def label(v) = "box:#{v.inspect}"
end

BOX = Box.new
def boxed = BOX.label(yield)

p shown { "a" }
p shown { 1.5 }
p shown { 7 }

p paired { "a" }
p paired { 1.5 }
p paired { nil }

p boxed { "a" }
p boxed { [1, 2] }

# the forms that already worked stay as they were
def plain = yield
def printed = puts(yield)
p plain { "a" }
p plain { 1.5 }
printed { "a" }
printed { 1.5 }
