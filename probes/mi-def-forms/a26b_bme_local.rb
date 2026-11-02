class K
  t = self
  t.class_eval do
    def b = :b
  end
end
p K.new.b
