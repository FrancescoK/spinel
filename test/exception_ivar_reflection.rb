# Instance-variable reflection on an exception held as an exception (a
# rescued `e`, `RuntimeError.new`): a builtin exception keeps its ivars in
# the runtime's map, one of the program's exception classes in its layout.
class Coded < StandardError
  def initialize(msg = "coded"); @code = 7; super; end
  attr_reader :code
end
class Plain < StandardError; end

ex = RuntimeError.new("boom")
ex.set_backtrace ["a:1"]
p ex.instance_variables
ex.instance_variable_set :@bindings, nil if ex.instance_variables.include? :@bindings
ex.instance_variable_set :@foo, 1
p ex.instance_variables, ex.instance_variable_get(:@foo)
p ex.instance_variable_defined?(:@foo), ex.instance_variable_defined?(:@bar)

def boom
  raise ArgumentError, "bad"
rescue => e
  e.instance_variable_set(:@where, "boom")
  raise
end
begin
  boom
rescue ArgumentError => e
  p e.instance_variables, e.instance_variable_get(:@where)
end

[0, 1].each do |i|
  begin
    i == 0 ? raise(Coded) : raise(ArgumentError, "a")
  rescue StandardError => e
    p e.instance_variables, e.instance_variable_get(:@code), e.instance_variable_defined?(:@code)
    e.instance_variable_set(:@code, 9)
    e.instance_variable_set(:@seen, i)
    p e.instance_variables
    p e.code if e.is_a?(Coded)
  end
end

m = Plain.new("x")
m.instance_variable_set(:@a, 1)
begin
  raise m
rescue StandardError => e
  p e.instance_variable_get(:@a)
  e.instance_variable_set(:@b, 2)
end
p m.instance_variables, m.instance_variable_get(:@b)

x = RuntimeError.new("a")
x.instance_variable_set(:@k, [1, 2])
p x.dup.instance_variables, x.clone.instance_variable_get(:@k)
y = x.exception("b")
p y.message, y.instance_variables
begin
  raise x, "c"
rescue => e
  p e.message, e.instance_variables
end
fr = x.dup.freeze
cl = fr.clone
p cl.frozen?
begin
  cl.instance_variable_set(:@q, 1)
rescue => err
  p err.class
end
n = nil
n = RuntimeError.new("n") if ARGV.size > 5
p n.instance_variables, n.instance_variable_get(:@k)
[RuntimeError.new("r"), x].each { |v| p v.instance_variables }
p x.inspect

# defined? in the class's own method sees a reflective set
class Tagged < StandardError
  attr_reader :tag
  def tagged?; defined?(@tag) ? "yes" : "no"; end
end
tx = Tagged.new("t")
p tx.tagged?
begin
  raise tx
rescue => e
  e.instance_variable_set("@tag", "T")
end
p tx.tag, tx.tagged?, Tagged.new("u").tagged?
