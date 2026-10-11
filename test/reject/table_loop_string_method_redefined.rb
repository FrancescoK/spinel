# The loop's String methods run at compile time only while they are the
# builtin ones. This program gives String a gsub of its own, so CRuby names
# the class Zed. The loop is left as written, which Spinel
# refuses.
class String
  def gsub(a, b); "Zed"; end
end
module M
  class Base; end
  T = { 1 => "O ne" }
  T.each { |c, n| const_set(n.gsub(/ /, ""), Class.new(Base)) }
end
p M.constants.sort
