# A class body's loop over a constant Hash that names classes with
# const_set is run at compile time only while Hash#each is the builtin one.
# Here the program gives Hash an each of its own, so CRuby defines Nine, not
# One. The loop is left as written, which Spinel refuses.
class Hash
  def each; yield 9, "Nine"; self; end
end
module M
  class Base; end
  T = { 1 => "One" }
  T.each { |c, n| const_set(n, Class.new(Base)) }
end
p M.constants.sort
