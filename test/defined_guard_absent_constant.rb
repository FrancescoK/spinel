VERSION = "1.0" unless defined?(VERSION)
p VERSION

module Config
  LIMIT = 10 unless defined?(LIMIT)
  def self.limit = LIMIT
end
p Config.limit

SIZE = 1
SIZE = 2 unless defined?(SIZE)
p SIZE

unless defined?(Widget)
  class Widget
    def self.kind = :widget
  end
  puts "defining Widget"
end
p Widget.kind

class Store
  if Object.const_defined?(:NoSuchBackend) && NoSuchBackend.ready?
    def backend = "native"
  else
    def backend = "pure"
  end

  if ObjectSpace.const_defined?(:NoSuchWeakMap)
    def cache = "weak"
  else
    def cache = "plain"
  end

  unless !defined?(Missing::Jit)
    def jit = "jit"
  else
    def jit = "interp"
  end
end
p Store.new.backend
p Store.new.cache
p Store.new.jit

if defined?(Never)
  Never = 1
end
p defined?(Never)
