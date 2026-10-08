# Flag-only: identity reads of a call's shared String answer see the handle,
# as a local assigned that answer does. The call still runs once, in order.
S = +"s"
def get = S
p get.equal?(S)
r = get
p r.equal?(S)
p S.equal?(get)
p get.equal?(get)
p get.equal?([S, 1][0])
p S.equal?((get))
p (get).equal?(((get)))
p get.object_id == S.object_id
p get.__id__ == S.__id__
get << "!"
p S
p get.frozen?
S.freeze
p get.frozen?

class Holder
  attr_reader :value, :reads
  def initialize(s)
    @value = s
    @reads = 0
  end
  def get
    @reads += 1
    @value
  end
  def through_begin
    begin
      @value
    rescue
      @value
    else
      @value
    end
  end
end
x = +"x"
obj = Holder.new(x)
x << "!"
p obj.get.equal?(x)
p x.equal?(obj.get)
p obj.get.equal?(obj.get)
p obj.reads
p obj.through_begin.equal?(x)
p x.equal?(obj.through_begin)
p obj.value.equal?(x)
p x.equal?(obj.value)
p obj.get.object_id == x.object_id
p obj.through_begin.object_id == x.object_id
p obj.get.frozen?
x.freeze
p obj.get.frozen?
p obj.through_begin.frozen?
p obj.value.frozen?

# Two calls publish different handles; the receiver must survive the second.
A = +"a"
B = +"b"
LOG = +""
def left
  LOG << "l"
  A
end
def right
  LOG << "r"
  B
end
A << "!"
B << "!"
p left.equal?(right)
p LOG

@held = +"ivar"
def ivar_get = @held
@held << "!"
p ivar_get.equal?(@held)
p @held.equal?(ivar_get)
p ivar_get.equal?(ivar_get)

def forwarded = get
p forwarded.equal?(S)
class Provider
  def self.get = S
end
p Provider.get.equal?(S)
bound = method(:get)
p bound.call.equal?(S)

# A fresh answer keeps its own identity; an unshared frozen literal stays frozen.
def fresh = +"s!"
def literal = "fixed"
p get.equal?(fresh)
p fresh.equal?(get)
p fresh.equal?(fresh)
p literal.frozen?

# A nullable return route carries either the handle or nil. Every identity
# form must observe that answer, directly and through a local.
def maybe_handle(flag)
  return nil unless flag
  S
end
p maybe_handle(false).equal?(nil)
p nil.equal?(maybe_handle(false))
p maybe_handle(false).equal?(maybe_handle(false))
p maybe_handle(false).equal?([nil, S][0])
p maybe_handle(false).object_id == nil.object_id
p maybe_handle(false).__id__ == nil.__id__
p maybe_handle(false).frozen?
p maybe_handle(true).equal?(S)
p maybe_handle(true).object_id == S.object_id
p maybe_handle(true).__id__ == S.__id__
p maybe_handle(true).frozen?
missing = maybe_handle(false)
p missing.equal?(nil)
p missing.equal?([nil, S][0])
p missing.object_id == nil.object_id
p missing.__id__ == nil.__id__
p missing.frozen?
def bare_handle(flag)
  return unless flag
  S
end
p bare_handle(false).equal?(nil)
p bare_handle(false).object_id == nil.object_id
p bare_handle(false).__id__ == nil.__id__
p bare_handle(false).frozen?
p bare_handle(true).equal?(S)
