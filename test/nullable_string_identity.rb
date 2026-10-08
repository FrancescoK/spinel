# A nullable String's nil has nil's identity, whether read from a call,
# a local or an ivar, including shared handles under --share-strings.
# spinel: gc-minor
# spinel: share
S = +"s"
def maybe(flag) = flag ? S : nil
S << "!"

p maybe(false).equal?(nil)
p nil.equal?(maybe(false))
p maybe(false).equal?(maybe(false))
p maybe(false).equal?(maybe(true))
p maybe(true).equal?(maybe(false))
p maybe(true).equal?(nil)
p maybe(false).equal?([nil, 1][0])
p maybe(true).equal?([nil, 1][0])
p maybe(false).equal?(false)
def maybe_number(flag) = flag ? 1 : nil
def maybe_array(flag) = flag ? [1] : nil
p maybe(false).equal?(maybe_number(false))
p maybe(false).equal?(maybe_number(true))
p maybe(false).equal?(maybe_array(false))
p maybe(false).equal?(maybe_array(true))
p maybe(false).object_id == nil.object_id
p maybe(false).__id__ == nil.__id__
p maybe(true).object_id == nil.object_id
p maybe(true).__id__ == nil.__id__
p maybe(false).frozen?
p maybe(true).frozen?

x = maybe(false)
p x.equal?(nil)
p nil.equal?(x)
p x.equal?(x)
p x.equal?([nil, 1][0])
p x.object_id == nil.object_id
p x.__id__ == nil.__id__
p x.frozen?
x = maybe(true)
p x.equal?(nil)
p x.object_id == nil.object_id
p x.__id__ == nil.__id__
p x.frozen?

class Holder
  attr_reader :value
  def initialize(flag)
    @value = maybe(flag)
  end
  def check
    p @value.equal?(nil)
    p nil.equal?(@value)
    p @value.equal?(@value)
    p @value.equal?([nil, 1][0])
    p @value.object_id == nil.object_id
    p @value.__id__ == nil.__id__
    p @value.frozen?
  end
end
empty = Holder.new(false)
full = Holder.new(true)
empty.check
full.check
p empty.value.equal?(nil)
p nil.equal?(empty.value)
p empty.value.object_id == nil.object_id
p empty.value.__id__ == nil.__id__
p empty.value.frozen?
p full.value.equal?(nil)
p full.value.object_id == nil.object_id
p full.value.__id__ == nil.__id__
p full.value.frozen?

# Each identity operation evaluates its operands once, receiver first.
LOG = +""
def left(flag)
  LOG << "l"
  maybe(flag)
end
def right(flag)
  LOG << "r"
  maybe(flag)
end
p left(false).equal?(right(false))
p LOG
p left(false).object_id == nil.object_id
p left(false).__id__ == nil.__id__
p LOG
