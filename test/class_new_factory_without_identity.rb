# Repeated factories work when their class identity is not observed.
class FactoryBase
  def value = 6
end
def make_static_class
  Class.new(FactoryBase) { def doubled = value * 2 }
end
p make_static_class.new.doubled
p make_static_class.new.doubled
