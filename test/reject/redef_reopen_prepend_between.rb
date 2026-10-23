# spinel: reject-subclass: a module prepended to the class defines it too
# A method redefined by a later reopening, called between the two
# definitions, in a class a module is prepended to that defines the
# method too: the call reaches the module's method from where the prepend
# runs, so it is refused.
module M; def get = 3; end
class B; def get = 1; end
p B.new.get
class B; prepend M; end
p B.new.get
class B; def get = 2; end
p B.new.get
