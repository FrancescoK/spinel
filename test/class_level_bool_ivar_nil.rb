# A class-level ivar (a class method's or a module_function's @x) is nil
# until something writes it, as an instance's is: a Bool or Symbol slot read
# before its first write answers nil, not its C zero, so the memoization
# below runs once and keeps its result.

module M
  module_function

  def avail?
    @avail = system('true') if @avail.nil?
    @avail
  end
end

module N
  def self.avail?
    @avail = system('true') if @avail.nil?
    @avail
  end

  def self.peek = @peek
  def self.set_peek = (@peek = false)
end

class K
  def self.ready?
    @ready = (1 > 0) if @ready.nil?
    @ready
  end

  def self.kind
    @kind ||= :fresh
  end
end

class C
  def avail?
    @avail = system('true') if @avail.nil?
    @avail
  end
end

p M.avail?, N.avail?, K.ready?, C.new.avail?
p N.peek
N.set_peek
p N.peek
p K.kind

# a class body that writes the ivar first leaves it set
class B
  @on = true
  def self.on? = @on
end
p B.on?
