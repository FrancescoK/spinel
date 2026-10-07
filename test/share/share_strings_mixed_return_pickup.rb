# Under --share-strings a method that answers its parameter (or another
# handle) on some paths and a fresh String on the others -- `unquote`
# slicing off quotes, `pick` falling back to File.join -- refused its
# callers that rebind a shared variable from it ("a String a method returns
# as its parameter is mutated in place"). Such a method now hands the
# caller the handle where it answers one, and a fresh tail clears the
# handover so the caller wraps the new String. (tools/spin/toml.rb's
# `iv = unquote(iv)` and tools/spin.rb's `install_dir` are these shapes.)
def pick(prefix)
  return prefix if prefix != ""
  d = ENV["SPINEL_NO_SUCH_VAR"].to_s
  return d if d != ""
  File.join("home", ".local/bin")
end
def unquote(s)
  return s[1..-2] if s.length >= 2 && s.start_with?("\"") && s.end_with?("\"")
  s
end
seen = []
a = +"pre"
seen << a
x = pick(a)
x << "!"
p a, x, x.equal?(a), seen
y = pick(+"")
y << "?"
p y, seen
q = +"\"quoted\""
seen << q
q = unquote(q)
q << "#"
p q, seen
r = +"bare"
seen << r
r = unquote(r)
r << "$"
p r, seen
