# `const_get(:Inner)` in a class method resolves against the class self is at
# run time: a subclass that defines its own Inner answers it, others the
# nearest ancestor's (ruby-vips' `GObject.ffi_managed_struct`).
class Base
  class Inner
    def self.tag = "base"
  end
  def self.inner = const_get(:Inner)
  class << self
    def inner2
      const_get :Inner
    end
  end
  def inner3 = self.class.inner2
end
class Kid < Base
  class Inner < Base::Inner
    def self.tag = "kid"
  end
end
class Other < Base
end
p Base.inner.tag, Kid.inner.tag, Other.inner.tag
p Base.inner2.tag, Kid.inner2.tag
p Kid.new.inner3.tag
