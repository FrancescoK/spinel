# A local or parameter written inside a begin (or a yield-inlined method's
# begin/ensure) and read after the rescue, retry or break keeps its value at -O2
# (#6552)
class Context
  attr_accessor :user

  def initialize
    @user = 47
  end
end

class TemporaryContext
  def self.run(context, value)
    saved = false
    begin
      previous = context.user
      saved = true
      context.user = value
      yield(context)
    ensure
      context.user = previous if saved
    end
  end
end

context = Context.new
result = TemporaryContext.run(context, 83) { break 59 }
p [result, context.user]
def pd(v = 5)
  n = 0
  begin
    n += 1
    r = v + 1
    v = 10 if n == 1
    raise "p" if n == 1
    r
  rescue RuntimeError
    retry
  end
end
p pd
p pd(1)
def pr(v)
  n = 0
  begin
    n += 1
    r = v + 1
    v = 10 if n == 1
    raise "p" if n == 1
    r
  rescue RuntimeError
    retry
  end
end
p pr(1)
