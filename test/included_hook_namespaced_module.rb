# `include M` runs the hook of the module the constant names where the include
# stands, looked up from the innermost namespace out, not of the first module
# that shares its last name.
module Ext
  def self.included(base) = puts("top-level Ext into #{base}")
end
module Outer
  module Ext
    def self.included(base) = puts("Outer::Ext into #{base}")
  end
  class Inner
    include Ext
  end
end
class A
  include Outer::Ext
end
class B
  include Ext
end
module Outer
  class C
    include ::Ext
  end
end
