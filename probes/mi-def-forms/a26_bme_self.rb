class K
  self.module_eval do
    def a = :a
  end
  t = self
  t.class_eval do
    def b = :b
  end
end
p K.new.a, K.new.b
