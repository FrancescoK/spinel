# A receiverless call in an instance_eval/exec block on a boxed receiver
# is sent to the receiver, a builtin value (Integer, String, Array, nil)
# as much as a user object.
class Foo
  def initialize = @v = 7
  def to_s = "foo"
  def name = "fooname"
end

class Bar
  def initialize = @v = 8
end

[1, Foo.new, "str", [1, 2], Bar.new, nil].each do |x|
  p x.instance_eval { to_s }.sub(/0x\h+/, "X")
  p x.instance_eval { inspect }.class
  p x.instance_exec(3) { |n| [n, @v] }
  begin
    p x.instance_eval { name }
  rescue NameError => e
    p [:name, e.class]
  end
  x.instance_eval { p self.class }
end
