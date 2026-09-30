# `alias` / `alias_method` inside a reopened builtin class. The alias names
# either a builtin method (starts_with? -> start_with?, the activesupport
# shape) or a method the reopen itself defined; both must dispatch on a
# concretely typed receiver, with arguments, on each of the primitives whose
# reopen Spinel dispatches (String, Integer, Float, Symbol).
class String
  alias starts_with? start_with?
  alias_method :ends_with?, :end_with?
  alias up upcase
  def shout = upcase + "!"
  alias yell shout
end

class Integer
  alias_method :plus, :+
  alias nxt succ
end

class Float
  alias_method :flo, :floor
end

class Symbol
  alias str to_s
end

s = "spinel"
p s.starts_with?("spin")
p s.ends_with?("nel")
p s.up
p s.yell
p "literal".starts_with?("lit", "x")
p 1.plus(2)
p 41.nxt
p 2.5.flo
p :sym.str
