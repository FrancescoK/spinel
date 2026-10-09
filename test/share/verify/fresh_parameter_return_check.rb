# A returned fresh argument can clear the channel after a publishing call.
def append_text(value)
  value << "!"
  value
end
def fresh_text(which)
  return "fixed" if which == 0
  return nil if which == 2
  append_text(+"fresh")
end
[0, 1, 2].each do |which|
  result = fresh_text(which)
  p result
end
result = fresh_text(1)
held = result
result << "?"
p held
