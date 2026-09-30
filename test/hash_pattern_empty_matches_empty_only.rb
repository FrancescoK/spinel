# The hash pattern `{}` matches only an empty Hash (and an object whose
# deconstruct_keys answers an empty one); `{a:}` matches a Hash that has more
# keys. `{a: 1, **nil}` and `{**nil}` close the pattern to the keys it lists, as
# `{}` does. `{}` is matched in a case, a one-line `in` and `=>`, an alternation,
# a nested pattern, an array element and a find pattern.
S = Struct.new(:a, :b)
D = Data.define(:x)

class Pt
  def initialize(x) = @x = x
  def deconstruct_keys(keys) = { x: @x }
end

class Nothing
  def deconstruct_keys(keys) = {}
end

def empty?(v)
  case v
  in {} then :empty
  else :other
  end
end

def closed?(v)
  case v
  in { **nil } then :empty
  else :other
  end
end

[{}, { a: 1 }, { "k" => 2 }, { 1 => 2 }, { a: { b: 1 } }].each do |h|
  p [empty?(h), closed?(h)]
end
p [empty?(S.new(1, 2)), closed?(S.new(1, 2))]
p [empty?(D.new(1)), closed?(D.new(1))]
p [empty?(Pt.new(1)), closed?(Pt.new(1))]
p [empty?(Nothing.new), closed?(Nothing.new)]
p [empty?(1), empty?(nil), empty?([]), empty?("s")]

def tried
  p yield
rescue NoMatchingPatternError => e
  p [:nomatch, e.class]
end

h = { a: 1 }
e = {}
tried { h => {}; :matched }
tried { e => {}; :matched }
tried { case h; in {} then :empty; in { a: Integer } then :a; end }
tried { case h; in {} | [] then :a; else :b; end }
tried { case e; in {} | [] then :a; else :b; end }
tried { case [1, {}, 3]; in [*, {}, *] then :found; else :none; end }
tried { case [1, { a: 2 }, 3]; in [*, {}, *] then :found; else :none; end }
tried { case [{}, { a: 1 }]; in [{}, {}] then :both; in [{}, { a: }] then a; end }
tried { case { x: { y: 1 } }; in { x: {} => inner } then inner; else :none; end }
tried { case { x: e }; in { x: {} => inner } then inner; else :none; end }
tried { case h; in {} if true then :guard; in { a: } then a; end }
tried { h in {} }
tried { e in {} }
tried { { "k" => 1 }.then { |v| v in {} } }
tried { { 1 => 2 }.then { |v| v in {} } }
tried { S.new(1, 2) in {} }
tried { D.new(1) in {} }
tried { Pt.new(1) in {} }
tried { Nothing.new in {} }

def kinds(v)
  case v
  in {} then :empty_hash
  in [] then :empty_array
  in Integer then :int
  else :other
  end
end
tried { [kinds({}), kinds({ a: 1 }), kinds([]), kinds([1]), kinds(3), kinds(nil), kinds("x")] }
tried { [{}, { a: 1 }].map { |v| case v; in {} then :e; else :n; end } }

# the patterns that were already right
tried { case { a: 1, b: 2 }; in { a: } then a; in {} then :never; end }
tried { case { a: 1 }; in { a: 1, **nil } then :closed; end }
tried { case { a: 1, b: 2 }; in { a: 1, **nil } then :closed; else :open; end }
tried { case { a: 1, b: 2 }; in { a: 1, **rest } then rest; end }
tried { case h; in { a: 1, **nil } | [] then :closed; else :open; end }
tried { case { a: 1, b: 2 }; in { a: 1, **nil } | [] then :closed; else :open; end }
