# A return annotation on a method that a subclass overrides is not applied
# (as with --rbs), and inline RBS says so; the parameter annotation still is.
class Base
  #: (untyped) -> untyped
  def size(x)
    x
  end
end

class Wide < Base
  def size(x)
    x * 2
  end
end

[Base.new, Wide.new].each { |o| p o.size(3) }
