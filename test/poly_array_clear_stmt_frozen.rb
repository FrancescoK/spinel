# Array#clear in statement position on a frozen polymorphic array raises
# FrozenError and keeps the elements, as the value form does; an unfrozen
# one still clears.
a = [1, "x"].freeze
begin
  a.clear
rescue FrozenError => e
  puts e.class
  puts e.message
end
p a
b = [2, :y]
b.clear
p b
