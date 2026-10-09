# spinel: share
# spinel: gc-minor
# String keys and values compare beyond an embedded NUL, including deletion.
s = {'a' => 'x', "a\0b" => "x\0y", "a\0c" => "x\0z"}
p s.value?('x'), s.has_value?("x\0y"), s.value?("x\0q")
p({'a' => 'x'}.value?("x\0y"))
p({1 => 'x'}.has_value?("x\0y"))
p({1 => "x\0y"}.value?('x'), {1 => "x\0y"}.value?("x\0y"))
p s.key?('a'), s.has_key?("a\0b"), s.include?("a\0q"), s.member?("a\0c")
p s.key("x\0y"), s.key("x\0q"), s.assoc("a\0c"), s.rassoc("x\0z")
p s.invert
p({'a' => 'x'} == {'a' => "x\0y"})
p({1 => 'x'} == {1 => "x\0y"})
p({'a' => "x\0y"} == {'a' => "x\0y"})
p s.delete("a\0b"), s.keys, s.values
p s.delete('a'), s.keys, s.values
n = {'a' => 1, "a\0b" => 2, "a\0c" => 3}
p n.delete("a\0b"), n.keys, n.values
p n.key?("a\0c"), n.include?("a\0q")
p({'a' => 1} == {"a\0b" => 1})
p({'a' => "\u00e9"}.value?("\u00e9".b))
p({1 => "\u00e9"}.value?("\u00e9".b))
p({'a' => 'x'}.value?('x'.b))
mixed = {'a' => 'x', 'b' => 1}
p mixed.value?("x\0y"), mixed.include?("a\0b")
symbols = {a: "x\0y"}
p symbols.value?('x'), symbols.has_value?("x\0y")
k = 'SPINEL_ENV_NUL_VALUES_B293'
v = 'spinel nul value b293'
ENV[k] = v
p ENV.value?(v), ENV.has_value?(v + "\0suffix")
p ENV.key(v + "\0suffix"), ENV.rassoc(v + "\0suffix")
ENV.delete(k)

poly = {'a' => 1, "a\0b" => 'two', "a\0c" => 3}
p poly.delete("a\0b"), poly.keys, poly.values
p poly.delete("a\0q"), poly.keys
p poly.delete("a\0c") { 'missing' }, poly.keys, poly.values
p poly.delete('a'), poly.keys, poly.values
poly = {'a' => 1, "a\0b" => 'two', "a\0c" => 3}
p poly.except("a\0b").keys, poly.except(*["a\0b"]).values
poly.delete_if { |key, value| key == "a\0b" }
p poly.keys, poly.values
p poly.shift, poly.shift, poly.keys

boxed = [{'a' => 1, "a\0b" => 'two', "a\0c" => 3}, 7][0]
p boxed.delete("a\0b"), boxed.keys, boxed.values
p boxed.delete("a\0c") { 'missing' }, boxed.keys, boxed.values
p boxed.delete("a\0q") { |key| key }, boxed.delete(1)
