# method_added: a def in a top-level class_eval block fires it
class K
  def self.method_added(n) = puts("added #{n}")
end
K.class_eval do
  def z; end
end
puts K.new.respond_to?(:z)
