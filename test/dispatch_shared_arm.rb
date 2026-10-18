# Subclasses that inherit a method share one arm of the dispatch on the
# receiver's class; a subclass with its own method keeps its arm.
class Base
  attr_reader :log
  def initialize; @log = []; end
  def name=(v); @log << "base=#{v}"; end
  def tag; "base"; end
  def put(a, b); @log << "base #{a} #{b}"; self; end
end
class A < Base; end
class B < Base; end
class C < Base
  def name=(v); @log << "c=#{v}"; end
  def tag; "c"; end
end
class D < Base
  def put(a, b); @log << "d #{a} #{b}"; self; end
end

def touch(o)
  o.name = "x"
  o.put(1, 2)
  o.tag
end

boxed = [Base.new, A.new, B.new, C.new, D.new, 1, "s"]
boxed.each do |o|
  if o.is_a?(Base)
    o.name = "y"
    o.put(3, 4)
    puts "#{o.class} #{o.tag} #{o.log.inspect}"
  end
end

typed = [Base.new, A.new, B.new, C.new, D.new]
typed.each { |o| puts "#{touch(o)} #{o.log.inspect}" }

begin
  boxed[5].put(1, 2)
rescue NoMethodError => e
  puts e.message[/undefined method '[^']+'/]
end
