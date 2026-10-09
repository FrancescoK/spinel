# spinel: rbs-seed-run
# A subclass returned through an ancestor-typed --rbs return compiles from a
# return deferred through an ensure and from a yielding method spliced at
# its call, as a flat return already did (#3418). Both assigned the
# subclass pointer to the ancestor slot without the cast (#8204).
class Base
  def initialize(n) = (@n = n)
  attr_reader :n
end
class Gadget < Base; end

class Holder
  def pick(f)
    begin
      return Gadget.new(8) if f
    ensure
      puts "ensure"
    end
    Base.new(2)
  end

  def pick_inline(f)
    yield
    return Gadget.new(8) if f
    Base.new(2)
  end
end

puts Holder.new.pick(true).n
puts Holder.new.pick(false).n
puts Holder.new.pick_inline(true) { }.n
puts Holder.new.pick_inline(false) { }.n
