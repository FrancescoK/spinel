# A reopening's alias of a method a required file defines binds for every
# call that runs after it, in a method of that file too, and in a class
# body after the alias: none of them runs before the alias, so none is
# refused (the class-body call ahead of an alias is, as in one file).
require_relative "alias_late_lib"
class Gauge
  alias_method :read, :scaled
end
p Gauge.new.read
p Gauge.new.via
class Gauge
  p new.read
end
