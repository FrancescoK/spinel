# slice!, delete_prefix! and delete_suffix! on a frozen String raise
# FrozenError, matched or not, as a statement or for their value; a
# mutable String still changes.
s = "hello"
begin
  s.slice!(0)
rescue FrozenError => e
  puts e.message
end
begin
  s.slice!(1, 2)
rescue FrozenError => e
  puts e.message
end
begin
  s.slice!(1..2)
rescue FrozenError => e
  puts e.message
end
begin
  s.slice!("zz")
rescue FrozenError => e
  puts e.message
end
begin
  s.delete_prefix!("h")
rescue FrozenError => e
  puts e.message
end
begin
  s.delete_suffix!("x")
rescue FrozenError => e
  puts e.message
end
begin
  p s.slice!("ll")
rescue FrozenError => e
  puts e.message
end
begin
  p s.slice!(/l+/)
rescue FrozenError => e
  puts e.message
end
begin
  p s.slice!(/(z)/, 1)
rescue FrozenError => e
  puts e.message
end
begin
  p s.slice!(1, 2)
rescue FrozenError => e
  puts e.message
end
p s

t = +"hello world"
t.slice!(0)
t.slice!(1, 2)
t.slice!("wo")
t.slice!(0..0)
t.delete_prefix!("l")
t.delete_suffix!("d")
p t
u = +"abcdef"
p u.slice!("f"), u.slice!(/e/), u.slice!(/(a)/, 1), u.slice!(0, 1), u
