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
