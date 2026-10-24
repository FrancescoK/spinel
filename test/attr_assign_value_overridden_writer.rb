# An attribute assignment in value position whose writer a subclass
# overrides (`r = (Base.new.a = s)`): the value is typed boxed, and the
# inline writer answered the String field's bytes into the boxed slot,
# which did not compile.
class Base
  attr_accessor :a
end
class Sub < Base
  def a=(v)
    @a = v + "!"
  end
end
s = +"s"
r = (Base.new.a = s)
p r.equal?(s)
r2 = (Sub.new.a = s)
p r2
