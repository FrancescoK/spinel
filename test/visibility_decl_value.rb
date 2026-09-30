# A visibility declaration in a value position answers what it declared: the
# name for one method, the Array of names for several, nil bare, and the class
# for private_class_method / public_class_method. It declares as the bare
# statement does.
class K
  def a = 1
  def b = 2

  x = private def f = 1
  p x
  p(protected def g = 2)
  y = public def h = 3
  p y
  p(private :a, :b)
  p(public :a)
  p(private [:a, :b])
  z = public [:b]
  p z
  p(private)
  def hidden = 4
  p(public)
  def shown = 5
  p(private_class_method def self.s = 6)
  p(public_class_method :s)

  def call_f = f
  def call_g(o) = o.g
  def call_hidden = hidden
end

k = K.new
p k.call_f, k.call_g(K.new), k.h, k.b, k.call_hidden, k.shown, K.s
p K.private_method_defined?(:f), K.protected_method_defined?(:g), K.public_method_defined?(:h)
p K.private_method_defined?(:a), K.public_method_defined?(:b)
p K.private_method_defined?(:hidden), K.public_method_defined?(:shown)
p k.respond_to?(:f), k.respond_to?(:a), k.respond_to?(:hidden)

module M
  p(module_function def mf = 7)
  def plain = 8
  w = module_function :plain
  p w
end
p M.mf, M.plain
