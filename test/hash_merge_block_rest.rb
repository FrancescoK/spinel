# A Hash#merge conflict block's rest parameter takes the values its
# positional ones leave, as CRuby's does (#8506).
p({a: 1}.merge({a: 2}) { |*args| args })
p({a: 1, b: 3}.merge({a: 2}) { |k, *r| r })
p({"x" => 1}.merge({"x" => 5}) { |k, o, *r| [k, o, r] })
p({a: 1}.merge({a: 2}) { |k, o, n| o + n })
