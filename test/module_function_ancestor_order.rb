# A receiverless call to a module_function that several ancestors could
# answer runs the one that comes first in the ancestor order: a module the
# class includes before one its superclass includes, the last of two
# includes, a module before the modules it includes, and a module the class
# includes before a method its superclass defines, and a module_function
# twenty includes deep before one the superclass includes.
module Older
  module_function
  def tag = "older"
end

module Newer
  module_function
  def tag = "newer"
end

class Base
  include Older
end

class Child < Base
  include Newer
  def show = tag
end

class Both
  include Older
  include Newer
  def show = tag
end

module Inner
  module_function
  def tag = "inner"
end

module Outer
  include Inner
  module_function
  def tag = "outer"
end

class Box
  include Outer
  def show = tag
end

class Plain
  def tag = "plain"
end

class Wrapped < Plain
  include Newer
  def show = tag
end

class Kept < Plain
  def show = tag
end

module Level0
  module_function
  def tag = "deep"
end
module Level1; include Level0; end
module Level2; include Level1; end
module Level3; include Level2; end
module Level4; include Level3; end
module Level5; include Level4; end
module Level6; include Level5; end
module Level7; include Level6; end
module Level8; include Level7; end
module Level9; include Level8; end
module Level10; include Level9; end
module Level11; include Level10; end
module Level12; include Level11; end
module Level13; include Level12; end
module Level14; include Level13; end
module Level15; include Level14; end
module Level16; include Level15; end
module Level17; include Level16; end
module Level18; include Level17; end
module Level19; include Level18; end

class Holder < Base
  include Level19
  def show = tag
end

p Child.new.show, Both.new.show, Box.new.show, Wrapped.new.show, Kept.new.show, Holder.new.show
