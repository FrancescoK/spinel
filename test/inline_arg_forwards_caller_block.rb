# A yielding method spliced at a call site with a literal block has no local
# for its &block parameter. An inlined blockless call inside it whose
# argument forwards that parameter (`note(each_item(&block))`) binds the
# argument as call-site code: it runs under the caller's block, not the
# callee's missing one, so the inner inline's block_given? answers true and
# the yields reach the literal block, and the to_enum generator of the same
# method does the same.
class Walker
  def initialize(items)
    @items = items
  end

  def each_item(&block)
    if block_given?
      @items.each(&block)
    else
      to_enum(:each_item)
    end
  end

  def each_item!(&block)
    if block_given?
      note(each_item(&block))
    else
      return to_enum(:each_item!)
    end
    self
  end

  def note(v)
    @last = v
    yield v if block_given?
    v
  end

  attr_reader :last
end

w = Walker.new([1, 2, 3])
w.each_item! { |x| puts x }
p w.last
e = w.each_item!
p e.class
e.each { |x| puts x * 10 }
