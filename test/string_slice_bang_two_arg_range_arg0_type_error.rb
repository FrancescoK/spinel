# frozen_string_literal: true
# String#slice!(range, n) has no two-argument overload that takes a Range
# first -- Ruby raises TypeError, after the receiver's own frozen check (a
# frozen receiver still raises FrozenError first, since CRuby checks
# mutability before argument shape) and after the second argument's own
# side effect, in the same left-to-right order Ruby evaluates both
# arguments in before dispatch can reject them. Found by CodeRabbit on
# PR #45 reviewing string_slice_bang_two_arg_nonvar_recv.rb's own fix: the
# combined span arm's TY_RANGE check never looked at argc, so a two-
# argument call with a Range first argument silently answered the
# one-argument Range-slice instead of raising -- true for ANY receiver
# this arm already served before that PR (str_fresh_value, a plain
# variable), not only the non-variable receivers that PR added.
def side(x)
  puts "eval #{x}"
  x
end

begin
  "abc".slice!(side(1..2), side(9))
rescue => e
  puts "#{e.class}: #{e.message}"
end

# `side` above takes two different argument types across its two call
# sites, so argv[0] here infers as poly rather than statically TY_RANGE,
# and never actually reaches emit_op_string_slice's TY_RANGE arm at all
# (it goes through the generic poly-argument path instead, which already
# evaluates both arguments correctly). side_r/side_i below each have a
# single, single-typed call site, so argv[0] infers as plain TY_RANGE and
# exercises the arm this file is actually about: an earlier version of
# the TypeError fix below referenced only argv[1] in its own generated
# code, so argv[0]'s side effect (side_r's own puts) never ran at all --
# CodeRabbit caught this reviewing matz/spinel#10593.
def side_r(x)
  puts "eval_r #{x}"
  x
end
def side_i(x)
  puts "eval_i #{x}"
  x
end
begin
  (+"abcdef").slice!(side_r(1..2), side_i(9))
rescue => e
  puts "#{e.class}: #{e.message}"
end

begin
  "abc".slice!(1..2, 9)
rescue => e
  puts "#{e.class}: #{e.message}"
end

begin
  (+"abcdef").slice!(1..2, 9)
rescue => e
  puts "#{e.class}: #{e.message}"
end

begin
  p (true ? +"abc" : +"def").slice!(0..1, 1)
rescue => e
  puts "#{e.class}: #{e.message}"
end

s = +"abcdef"
begin
  s.slice!(1..2, 9)
rescue => e
  puts "#{e.class}: #{e.message}"
end
p s
