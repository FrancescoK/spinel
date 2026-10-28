# The definitions of a class body that no statement of the load phase
# places (--dump-load-record, record_unplaced_defs_main.rb.load-record): an
# include, an attr, a def, a visibility change and an alias in a class body
# written as an argument are its class's, marked unplaced, and no query at
# a point sees them (end=no), as the mixin is in the class's line.
module M; def hi = "hi"; end
p(class G
  include M
  attr_reader :z
  def y = 1
  private :y
  alias_method :w, :y
  undef_method :hi
  self
end)
