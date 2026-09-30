# Hash#eql? compares values with eql?, so a Hash key is found only by an eql? Hash
class Pt
  attr_reader :v
  def initialize(v); @v = v; end
  def ==(o); o.is_a?(Pt) && v == o.v; end
  def eql?(o); o.is_a?(Pt) && v.eql?(o.v); end
  def hash; v.hash; end
end

p({a: 1}.eql?({a: 1.0}))
p({a: 1} == {a: 1.0})
p({a: 1}.eql?({a: 1}))
p({a: 1.0}.eql?({a: 1.0}))
p({"a" => 1}.eql?({"a" => 1.0}))
p({"a" => 1}.eql?({"a" => 1}))
p({1 => 1}.eql?({1 => 1.0}))
p({1 => 2}.eql?({1 => 2}))
p({1 => "x"}.eql?({1 => "x"}))
p({"a" => "b"}.eql?({"a" => "b"}))
p({a: 1, b: "x"}.eql?({a: 1.0, b: "x"}))
p({a: 1, b: "x"}.eql?({b: "x", a: 1}))
p({a: nil}.eql?({a: nil}))
p({a: 2**70}.eql?({a: (2**70).to_f}))
p({a: [1]}.eql?({a: [1.0]}))
p({a: [1, {b: 2}]}.eql?({a: [1, {b: 2.0}]}))
p({a: [1, {b: 2}]}.eql?({a: [1, {b: 2}]}))
p({a: {b: 1}}.eql?({a: {b: 1.0}}))
p({a: {b: 1}} == {a: {b: 1.0}})
p([{a: 1}].eql?([{a: 1.0}]))
p([{a: 1}].eql?([{a: 1}]))
p({a: Pt.new(1)}.eql?({a: Pt.new(1)}))
p({a: Pt.new(1)}.eql?({a: Pt.new(1.0)}))
p({a: Pt.new(1)} == {a: Pt.new(1.0)})
p [{a: 1}, {a: 1.0}, {a: 1}].uniq

x = {a: 1}
x[:self] = x
y = {a: 1}
y[:self] = y
p x.eql?(y)

p({a: 1, b: "x"}.hash == {b: "x", a: 1}.hash)
h = {{a: 1} => :one}
p h[{a: 1}]
p h[{a: 1.0}]
p h.key?({a: 1})
g = {{"x" => [1, 2]} => 1}
p g[{"x" => [1, 2]}]
p g[{"x" => [1.0, 2]}]
p [{a: 1}, {a: 1}].tally
