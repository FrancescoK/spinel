# An empty receiver still binds the arguments of an Array reopening.
# spinel: gc-minor
# spinel: share
class BindingValue
  def inspect = "value"
end
class Array
  def binding_options(first = 51, *rest, last, known: 70, **extra, &block)
    [first, rest, last, known, extra, block && block.call]
  end
  def binding_yield(*rest, last, known:, &block)
    return [rest, last, known, block.call] if ($binding_turn = !$binding_turn)
    yield
  end
end
args = [3, 4]
block = proc { :block }
p [].binding_options(BindingValue.new, 2, *args, known: 5, **{"s" => 6}, &block)
p [].binding_options(*[1], **nil)
2.times { p [].binding_yield(*[1], **nil, known: 2) { :yielded } }
