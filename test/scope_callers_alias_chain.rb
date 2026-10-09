# A method reached only through an alias of an alias: the walk back from its
# container parameter to the callers finds the call, so the Strings the
# caller's Array holds take the appends.
class Shout
  def bang(words)
    words.each { |w| w << "!" }
    words
  end
  alias_method :yell, :bang
  alias_method :roar, :yell
end

Shout.new.bang([])
list = ["a".dup, "b".dup]
Shout.new.roar(list)
puts list.join(",")
first = list[0]
Shout.new.roar([first])
puts first
puts list.inspect
