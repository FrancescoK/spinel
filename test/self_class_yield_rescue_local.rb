# A local a block writes before it raises out of `self.class.run { }`, whose
# inlined body rescues around the yield, keeps the write (#10291): the
# block is spliced under that setjmp, so the local is volatile, as it is
# for `Thing.run { }`.
class Base
  def self.run
    yield
  rescue StandardError
    nil
  end
end

class Thing < Base
  def via_self_class
    flag = true
    self.class.run do
      flag = false
      raise "x"
    end
    flag
  end

  def via_constant
    flag = true
    Thing.run do
      flag = false
      raise "x"
    end
    flag
  end

  def via_self_class_no_raise
    flag = true
    self.class.run do
      flag = false
    end
    flag
  end
end

t = Thing.new
puts "self.class, raise: #{t.via_self_class.inspect}"
puts "constant, raise: #{t.via_constant.inspect}"
puts "self.class, no raise: #{t.via_self_class_no_raise.inspect}"
