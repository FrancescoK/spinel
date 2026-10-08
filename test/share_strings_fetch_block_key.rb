# spinel: gc-minor
# A missing String key keeps its frozen state and bytes when fetch binds
# a handle parameter, beside fetch blocks that still use typed keys.
def source(n) = n > 0 ? {"present" => 1, :present => 2, 3 => 4} : [10, 20]

def retained_key(n)
  table = source(n)
  table.fetch("mi\0ss") { |key| key }
end

kept = retained_key(1)
p kept, kept.bytes, kept.frozen?
begin
  kept << "!"
rescue FrozenError
  puts "frozen key"
end

h = source(1)
p h.fetch(:missing) { |symbol| symbol.to_s }
w = source(1)
p w.fetch("missing") { |text| text.size }
p w.fetch("present") { |text| text + "!" }
p h.fetch(9) { |index| index * 2 }
p h.fetch(3) { |index| index * 2 }
a = source(0)
p a.fetch(9) { |index| index * 2 }
p a.fetch(1) { |index| index * 2 }

# Concrete Hash receivers use the same parameter binder.
typed = {"present" => 1}
frozen_key = typed.fetch("lost") { |key| key }
p frozen_key.frozen?
begin
  frozen_key << "!"
rescue FrozenError
  puts "typed frozen key"
end
