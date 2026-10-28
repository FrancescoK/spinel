# A branch whose condition is a constant runs whenever the condition is
# reached, as the scope walk folds it (`attr_reader :a if true`): the load
# record holds its definitions and writes as sure, those of an arm after
# one that always runs as may not run, and the else of a condition that
# never holds as sure (--dump-load-record,
# record_const_pred_main.rb.load-record). A def under such a condition is
# folded before the record (desugar_conditional_defs).
class A
  attr_reader :a if true
  attr_writer :b unless false
  if false then attr_reader :c else attr_accessor :d end
  if ENV["NO_SUCH_VARIABLE_X"] then attr_reader :e elsif true then attr_reader :f end
  if true then attr_reader :i else attr_reader :j end
  def h = 7
  alias g h if true
end
$w = 1 if true
p A.new.g, $w
