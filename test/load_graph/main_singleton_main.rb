# A required file's top-level `def self.m` is a singleton method of main,
# as the entry file's is: its own top level and the entry's calls on main
# find it before Object's `def m`, which another object's call finds.
require_relative "main_singleton_lib"
p m
p self.m
class C
  def x = m
end
p C.new.x
