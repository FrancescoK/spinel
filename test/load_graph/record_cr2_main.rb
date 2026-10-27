# The load record's answers for three more shapes (--dump-load-record,
# record_cr2_main.rb.load-record): a bare `private` in a body whose class
# the record does not know is still recorded for that body; a module's
# lexical read of a top-level module finds it through Object; and a
# visibility change in an ancestor module reaches a class that includes
# it, and an alias there.
module TopHelper
  def help = "top"
end
module M
  include TopHelper
end
module V
  def f = "f"
  private :f
end
class C
  include V
  alias_method :g, :f
  def call_g = g
end
Pt = Struct.new(:a) do
  private
  def secret = a * 2
  public
  def shown = secret + 1
end
class Q
  include M
end
puts Q.new.help
puts C.new.call_g
p C.private_instance_methods(false).sort
puts Pt.new(1).shown
