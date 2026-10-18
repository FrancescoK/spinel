# `extend self` makes a module's attr_accessor / attr_reader / attr_writer
# answer on the module too, in the body that extends it and in a reopening
# (activesupport's XmlMini sets `self.depth = 100` after `attr_accessor
# :depth`); a class method the module defines itself keeps its place.
module Conf
  extend self
  attr_accessor :depth
  self.depth = 100
end

module Conf
  attr_reader :label
  attr_writer :mode
  attr_accessor :owned, :level
  def self.owned = :class_side
  @label = "conf"
  def mode_now = @mode
end

p Conf.depth
Conf.depth = 7
p Conf.depth
p Conf.label
Conf.mode = :fast
p Conf.mode_now
p Conf.owned
Conf.level = 3
p Conf.level

class User
  include Conf
end
u = User.new
u.depth = 1
u.owned = :mine
p u.depth, u.owned, Conf.depth
