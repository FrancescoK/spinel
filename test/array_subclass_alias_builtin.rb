# An alias of one of Array's methods in an Array subclass, ahead of the
# class's own definition of the name, keeps naming Array's (#7449): the
# override calls it, with or without self, without calling itself.
class Log < Array
  alias_method :raw_push, :push
  alias_method :raw_size, :size
  def push(x)
    raw_push("[#{x}]")
  end
  def size = raw_size * 10
  def true_size = self.raw_size
end
l = Log.new
l.push(1)
l.push("a")
p l, l.size, l.true_size, l.class
