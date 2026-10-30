# A method the program names `__inc <n> <name>`, in a class whose include
# copies do not have that name, is its own method: listed, answered by
# respond_to? and send, and __method__ and original_name give the name written.
class C
  def foo = "C"
  define_method(:"__inc 0 foo") { "user" }
  define_method(:"__inc 3 zap") { __method__ }
end
c = C.new
p C.instance_methods(false).sort
p [c.respond_to?(:"__inc 0 foo"), c.respond_to?(:"__inc 3 zap")]
p c.send(:"__inc 0 foo")
p c.public_send(:"__inc 3 zap")
p c.method(:"__inc 3 zap").original_name
p C.method_defined?(:"__inc 3 zap")
