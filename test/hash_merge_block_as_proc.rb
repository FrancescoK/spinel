# Hash#merge and ENV.merge! / update given their conflict block as a proc
# (`&pr`, `&proc { }`): the proc decides the value. The literal-block arms
# read no body from it and stored nil for every conflict.
p [{ a: 1 }, { b: 2 }, { a: 3 }].reduce({}) { |acc, hh| acc.merge(hh, &proc { |_k, o, n| o + n }) }
pr = proc { |_k, o, n| o * n }
h = {"x" => 2}
p h.merge({"x" => 5}, &pr)
acc = {}
acc = acc.merge({k: 1})
p acc.merge({k: 4}, &pr)
ENV["SP_B"] = "1"
ENV.merge!({ "SP_B" => "0" }, &proc { |k, o, n| "#{k}!" })
p ENV["SP_B"]
pr = proc { |k, o, n| o + n }
ENV.update({ "SP_B" => "z" }, &pr)
p ENV["SP_B"]
