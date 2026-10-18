# slice! and slice with a boxed index that is a Range on some calls and a
# Float or an Integer on others. Only [] and []= took the Range at run
# time: slice! removed the element at the index the Range was read as
# (TypeError), and slice read it the same way.
def pick(n)
  if n == 0 then 1.5
  elsif n == 1 then (1..)
  elsif n == 2 then (1..2)
  elsif n == 3 then (1...3)
  elsif n == 4 then (..-2)
  elsif n == 5 then (7..9)
  else -1
  end
end

7.times do |n|
  a = [1, 2, 3, 4]
  p [n, a.slice!(pick(n)), a]
  f = [1.5, 2.5, 3.5, 4.5]
  p [n, f.slice!(pick(n)), f]
  s = %w[a b c d]
  p [n, s.slice!(pick(n)), s]
  m = [1, "b", :c, 4.0]
  p [n, m.slice!(pick(n)), m]
  p [n, [1, 2, 3, 4].slice(pick(n)), %w[a b c d].slice(pick(n))]
end
