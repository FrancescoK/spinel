# `gsub`/`sub` on a widened (poly) receiver handled a regex LITERAL pattern
# only. A Regexp known only at run time -- `Regexp.new(s)`, or a local or
# parameter holding one -- fell through to a generated NoMethodError
# claiming a String had no #gsub, though the same call on a String-typed
# receiver dispatches to the compiled-pattern engine.

def normalize(name, canonical)
  result = name.strip
  result.gsub(Regexp.new(Regexp.escape(canonical), Regexp::IGNORECASE), canonical)
end

def with_local(v)
  r = Regexp.new("a")
  v.gsub(r, "b")
end

def with_param(v, r)
  v.gsub(r, "b")
end

def first_only(v, r)
  v.sub(r, "B")
end

def by_hash(v, r)
  v.gsub(r, "a" => "1", "n" => "2")
end

items = ["  ci/cd pipelines  ", 42]
v = items[0]
w = ["banana", :x][0]

puts normalize(v, "CI/CD")
puts with_local(w)
puts with_param(w, /a/)
puts first_only(w, Regexp.new("an"))
puts by_hash(w, Regexp.new("[an]"))
puts w.gsub(/a/, "b")
