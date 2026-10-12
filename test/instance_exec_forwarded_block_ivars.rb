# A block given in a class body to a class method that runs it on an
# instance it makes (`instance.instance_exec(&block)`) reads that instance's
# ivars, as CRuby's does. The class-body ivar rewrite took the block for
# class-level code and read the class's own @name (nil), and a typed ivar's
# method call crashed on the NULL it read (#8659).
class R
  def initialize = @v = "hello-r"
  def v = @v
end

class C
  def initialize
    @name = "hello"
    @r = R.new
    @n = 3
  end

  def r = @r

  def self.check(name, &block)
    instance = new
    instance.instance_exec(&block)
  end

  def self.run(&)
    new.instance_eval(&)
  end

  check "demo" do
    puts @name.nil? ? "IVAR=NIL" : "IVAR=#{@name}"
  end
  check "direct" do
    puts @r.v
  end
  check "helper" do
    puts r.v
  end
  run { p @n + 1 }

  @klass_level = "class"
  def self.klass_level = @klass_level
end
p C.klass_level
