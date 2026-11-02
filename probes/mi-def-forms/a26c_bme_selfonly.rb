class K
  self.module_eval do
    def a = :a
  end
  p new.a
end
p K.new.a
