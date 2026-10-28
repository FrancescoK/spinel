# A method redefined by a later reopening, called between the two
# definitions, in a class a module is prepended to that defines the
# method too: each call reaches the method in effect where it runs, the
# class's first definition ahead of the prepend and the module's from it
# on (it was refused).
module M; def get = 3; end
class B; def get = 1; end
p B.new.get
class B; prepend M; end
p B.new.get
class B; def get = 2; end
p B.new.get
