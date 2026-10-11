# `+=` onto an Array slot whose rhs inference cannot type: a call no class
# defines raises NoMethodError when it runs, so the slot keeps its value.
# The ivar form was refused as "a mismatched array kind", the local one as
# an unsupported operator assignment.
class Listeners
  attr_reader :list

  def initialize
    @list = []
    @count = [0]
  end

  def listen
    @list += Missing.sockets
  end

  def bump
    @count += Missing.counts
  end
end

l = Listeners.new
begin
  l.listen
rescue NameError => e
  puts e.class
end
p l.list
begin
  l.bump
rescue NameError => e
  puts e.class
end

x = []
begin
  x += Object.new.no_such_method
rescue NoMethodError => e
  puts e.class
end
p x

