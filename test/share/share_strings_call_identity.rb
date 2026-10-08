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
