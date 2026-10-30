# merge!/update into a hash parameter of a hash that is a boxed keyword
# parameter, its callers passing hashes of different kinds: each call's hash
# for the keyword is checked against the receiver's, as a positional's is.
def assign(obj, source:)
  obj.merge!(source)
  obj
end
p assign({ "a" => 1 }, source: { "b" => 2 })
p assign({ "c" => "x" }, source: { "d" => [1] })
x = { "q" => :s }
p assign(x, source: { "e" => 1 })
p x

def upd(obj, source:) = obj.update(source)
p upd({ 1 => 2 }, source: { 3 => 4 })
p upd({ 1 => 2 }, source: { "k" => 1.5 })

# replace takes its source the same way
def rep(obj, source:) = obj.replace(source)
p rep({ "a" => 1 }, source: { "b" => 2 })
p rep({ "c" => "x" }, source: { "d" => [1] })

# an optional keyword, given or not, in either order beside another
def opt(obj, tag: nil, source: { "z" => 0 })
  obj.merge!(source)
  [tag, obj]
end
p opt({ "a" => 1 })
p opt({ "a" => 1 }, source: { "b" => 2 }, tag: :t)
p opt({ "c" => "x" }, tag: "u", source: { "d" => [1] })

# a keyword after a rest, named or not, and one handed on from there
def after_rest(obj, *r, source:) = obj.merge!(source)
p after_rest({ "a" => 1 }, source: { "b" => 2 })
p after_rest({ "c" => "x" }, 1, source: { "d" => [1] })
def after_anon(obj, *, source:) = obj.merge!(source)
p after_anon({ "a" => 1 }, source: { "b" => 2 })
p after_anon({ "c" => "x" }, source: { "d" => [1] })
def rest_on(o, *r, s:) = after_rest(o, source: s)
p rest_on({ "a" => 1 }, s: { "b" => 2 })
p rest_on({ "c" => "x" }, s: { "d" => [1] })

# several sources, a positional and a keyword
def two(obj, a, b:) = obj.update(a, b)
p two({ "a" => 1 }, { "b" => 2 }, b: { "c" => 3 })
p two({ "a" => 1 }, { "b" => 2 }, b: { :c => [3] })

# a caller handing on its own parameter as the keyword, from a keyword or a
# positional
def from_kw(o, s:) = assign(o, source: s)
p from_kw({ "a" => 1 }, s: { "b" => 2 })
p from_kw({ "c" => "x" }, s: { :d => [1] })
def from_pos(o, s) = assign(o, source: s)
p from_pos({ "a" => 1 }, { "b" => 2 })
p from_pos({ "c" => "x" }, { :d => [1] })

# a keyword handed on as a positional source
def pos_assign(obj, source) = obj.merge!(source)
def kw_to_pos(o, s:) = pos_assign(o, s)
p kw_to_pos({ "a" => 1 }, s: { "b" => 2 })
p kw_to_pos({ "c" => "x" }, s: { "d" => [1] })
