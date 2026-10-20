# A method reference by a computed name on a receiver of no known class
# (`mod.instance_method(name)`, mod a parameter its calls hand a module
# read out of an Array literal) reaches the methods of the classes and
# modules its sources name, not every method: an unrelated parameter
# defaulting to ENV, beside a method that changes a String in place, is not
# taken as a String the reference could hand another name (#9627).
module Helpers
  def path_for(x) = "/#{x}"
end

def ref(mod, name) = mod.instance_method(name)
shared = [Helpers, 1][0]
p ref(shared, ARGV[0].to_sym).name if ARGV[0]

def shout(s) = s.upcase!
def lookup(env = ENV) = env["SPINEL_NO_SUCH_VAR_9627"]
t = +"hi"
shout(t)
p t, lookup
