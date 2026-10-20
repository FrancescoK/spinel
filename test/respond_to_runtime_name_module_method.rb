# A receiverless `respond_to?(name)` with a run-time name in a module's
# instance method, run on instances of classes that include the module and on
# main after a top-level `include` / `extend`.
module M
  def mq?(n) = respond_to?(n.to_sym)
  def mm = 1
end

module N
  def nq?(n) = respond_to?(n.to_sym)
  def nn = 1
end

class C
  include M
  def cm = 1
end

include M
extend N
p [mq?("m" + "m"), C.new.mq?("c" + "m"), C.new.mq?("m" + "m")]
p [mq?("zz" + "z"), C.new.mq?("zz" + "z")]
p [nq?("n" + "n"), nq?("zz" + "z")]
