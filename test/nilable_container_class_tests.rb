# An Array or a Hash an instance variable holds before it is set (or a
# method answers beside a nil) is nil as a NULL pointer: the class tests
# (is_a?, kind_of?, instance_of?, Class ===, case/when), equal? and eql?
# with nil or a boxed operand read that nil, as nil? does. Before, they
# folded on the static type, and the nil answered as an Array or a Hash.
class NcctHolder
  def initialize
    @h = nil
    @a = nil
  end

  def set
    @h = { "a" => 1 }
    @a = [1, 2]
    self
  end

  def tests
    r = []
    r << @h.is_a?(Hash) << @a.is_a?(Array) << @h.kind_of?(Hash) << @a.instance_of?(Array)
    r << (Hash === @h) << (NilClass === @h) << (Array === @a) << (NilClass === @a)
    r << @a.is_a?(Enumerable) << @h.is_a?(Object) << @a.is_a?(String)
    r << @h.nil? << @a.nil? << (@h == nil) << (@a == nil)
    r << @h.equal?(nil) << @a.equal?(nil) << @h.equal?(@h) << @a.equal?(@a)
    r << @h.equal?([@h][0]) << @a.equal?([nil][0]) << @a.equal?([@a][0])
    r
  end

  def cases
    r = []
    r << (case @h when nil then :nil when Hash then :hash end)
    r << (case @a when nil then :nil when Array then :array else :other end)
    r << (case @h when Hash then 1 else 2 end)
    r << (case @a when NilClass then 1 else 2 end)
    case @h
    when Hash then r << :stmt_hash
    else r << :stmt_other
    end
    r
  end
end

x = NcctHolder.new
p x.tests, x.cases
x.set
p x.tests, x.cases
