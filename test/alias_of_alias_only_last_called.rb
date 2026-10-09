# A method called only through an alias of an alias: the method is
# reachable, so it is compiled (the alias names no scope of its own, and the
# middle one is called by nobody).
class Shout
  def bang(s) = s + "!"
  alias_method :yell, :bang
  alias_method :roar, :yell

  def calm = "calm"
  alias quiet calm
  alias hush quiet
end

puts Shout.new.roar("hey")
puts Shout.new.hush
