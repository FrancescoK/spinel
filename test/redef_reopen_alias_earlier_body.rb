# An alias made while a reopened class's method has its earlier body names
# that body, also when a later reopening defines the method again: in the
# same class body after the def, in a reopening ahead of the later def,
# with or without a call in between.
class A; def get = 1; alias old get; end
class A; def get = 2; end
p A.new.old, A.new.get

class B; def get = 1; end
class B; alias_method :old, :get; end
p B.new.get
class B; def get = 2; end
p B.new.old, B.new.get

class C; def get = 1; alias old get; end
p C.new.get
class C; def get = 2; end
p C.new.old, C.new.get
