# Base's alias fmt names Base's to_fs; Mid between Base and Leaf aliases
# fmt only on its singleton, which no instance resolves, and Leaf includes
# a module with its own to_fs: CRuby prints "base" for Leaf.new.fmt. The
# alias names a copy of the body in effect where it appears, which Leaf's
# chain does not take (it was refused before).
class Base
  def to_fs = "base"
  alias_method :fmt, :to_fs
end
class Mid < Base
  class << self
    def to_fs = "class side"
    alias_method :fmt, :to_fs
  end
end
module Ext
  def to_fs = "ext"
end
class Leaf < Mid
  include Ext
end
puts Leaf.new.fmt
