# A frozen Hash's FrozenError names the Hash, as CRuby's message does.
h = { k: 1 }.freeze
[-> { h[:j] = 2 }, -> { h.delete(:k) }, -> { h.merge!(a: 1) }, -> { h.clear }, -> { h.store(:z, 1) }].each do |f|
  f.call
rescue FrozenError => e
  puts e.message
  p e.receiver.equal?(h)
end
s = { "a" => [1] }.freeze
begin
  s["b"] = [2]
rescue FrozenError => e
  puts e.message
end
