# `respond_to?(:m)` on a receiver of a known class is answered at compile
# time; a branch it rules out is dropped rather than compiled, so a call it
# guards -- one the class has no method for -- is never a refusal.
# activesupport's safe_constantize:
#   message = e.respond_to?(:original_message) ? e.original_message : e.message
# (Zeitwerk adds original_message to LoadError; plain Ruby has none.)

def load_it(name)
  raise LoadError, "cannot load #{name}"
rescue LoadError => e
  message = e.respond_to?(:original_message) ? e.original_message : e.message
  "#{message}!"
end
p load_it("foo")

class Plain
  def name = "plain"
end
class Titled
  def name = "titled"
  def title = "Dr."
end

# the statement form, both ways round
def describe(o)
  if o.respond_to?(:title)
    "#{o.title} #{o.name}"
  else
    o.name
  end
end
def describe2(o)
  unless o.respond_to?(:title)
    return o.name
  end
  o.title
end
p describe(Plain.new), describe(Titled.new)
p describe2(Plain.new), describe2(Titled.new)

# the true branch is kept when the method exists
f = ->(a, b) { a + b }
p(f.respond_to?(:arity) ? f.arity : -99)
p(f.respond_to?(:nonesuch) ? f.nonesuch : "no nonesuch")
