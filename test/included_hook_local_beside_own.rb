# A hook's locals are the hook call's own, apart from the includer's and the
# top level's locals of the same names: the includer's `x` keeps its String
# after the hook writes its `x`, the top level's keeps its Symbol, and a
# class_eval block's local is the block's, the hook's block and the
# includer's own block alike.
x = :top
module Hook
  def self.included(base)
    x = 5
    p x + 1
    base.class_eval do
      y = 7
      define_method(:hy) { y }
    end
  end
end

module Ext
  def self.extended(base)
    x = :hook
    p x
  end
end

class U
  x = "s"
  y = 2
  include Hook
  p x.upcase
  p y
  class_eval do
    z = 5
    define_method(:bz) { z }
  end
  z = 1
  p z
end
p U.new.hy, U.new.bz

module M
  x = :mine
  extend Ext
  p x
end
p x
