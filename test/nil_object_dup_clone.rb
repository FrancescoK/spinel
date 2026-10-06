# dup and clone of a user object that may be nil: nil's dup and clone answer
# nil itself, and clone(freeze: false) is CRuby's ArgumentError (nil cannot
# be unfrozen). The struct copy read through the NULL that nil is (SIGSEGV).
# A live object is still copied, with its initialize_copy hook and its
# frozen state.

class K
  attr_accessor :a
  def initialize(a) = @a = a
end
class H
  attr_reader :log
  def initialize = @log = []
  def initialize_copy(src) = @log = src.log + [:copied]
end

def v(k) = k == 0 ? nil : K.new(k)
def hv(k) = k == 0 ? nil : H.new

p v(0).dup, v(0).clone, v(0).clone(freeze: true)
p((v(0).clone(freeze: false) rescue $!.class), (v(0).clone(freeze: false) rescue $!.message))
p hv(0).dup, hv(0).clone, hv(1).dup.log, hv(1).clone.log

x = ARGV.size == 9 ? K.new(1) : nil
p x.dup, x.clone
y = v(2)
z = y.dup
z.a = 5
p y.a, z.a, y.clone(freeze: true).frozen?, y.dup.frozen?
p [0, 1, 2].map { |k| v(k).dup&.a }
f = v(3).freeze
p f.clone.frozen?, f.dup.frozen?, (f.clone(freeze: false).frozen?)
