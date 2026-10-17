# spinel: rbs-seed-run
# `||` and `&&` in a seeded return are judged operand by operand, but only
# for the values an operand answers with: the left of `||` when truthy, the
# left of `&&` when falsy. None of these contradicts `-> String`: the left of
# an `||` that is nil or false, or that a method, a `begin` or an `&&` only
# ever answers false for, a left of `&&` that can only be truthy (an Integer,
# a conditional of Strings, `true`) and a nil operand, which every slot holds.
class SeedRetLogic
  def initialize(s, n) = (@s = s; @n = n)
  def s = @s
  def n = @n
  def t = "t"
  def nilv = nil
  def falsev = false
  def left_or = (nil || s)
  def false_or = (false || s)
  def and_int = (n && s)
  def and_cond = ((n > 1 ? "a" : "b") && s)
  def or_chain = (s or "t" or nilv)
  def false_call_or = (falsev) || s
  def ensure_or = (begin; falsev; ensure; 1; end) || s
  def and_false_or = (t && falsev) || s
  def nil_call_or = (nilv || falsev) || s
  def true_and = (true && s)
end

o = SeedRetLogic.new("str", 5)
p o.left_or, o.false_or, o.and_int, o.and_cond, o.or_chain, o.false_call_or, o.ensure_or,
  o.and_false_or, o.nil_call_or, o.true_and
