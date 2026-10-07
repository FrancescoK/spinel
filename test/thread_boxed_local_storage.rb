t = [Thread.new { 7 }, 0][0]
t[:answer] = 42
p [t[:answer], t.key?(:answer)]

p [t[:absent], t.key?(:absent)]
p(t[:answer] = 43)
t["answer"] = 44
p [t[:answer], t["answer"], t.key?("answer")]
[:dynamic, "string_key"].each do |key|
  t[key] = [key, 17]
  GC.start
  p [t[key], t.key?(key)]
end
t[:false_value] = false
p [t[:false_value], t.key?(:false_value)]
t[:answer] = nil
p [t[:answer], t.key?(:answer)]
# A key that is neither a Symbol nor a String is a TypeError.
[1, nil, 1.5].each do |key|
  begin
    t[key]
  rescue TypeError => e
    p e.message
  end
  begin
    t[key] = 1
  rescue TypeError => e
    p e.message
  end
end
t.join
