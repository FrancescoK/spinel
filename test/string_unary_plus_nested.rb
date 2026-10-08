# A nested unary + follows the String handle through each wrapper once.
# Frozen receivers give mutable copies; mutable receivers keep their identity.
# spinel: gc-minor
s = "ab"
t = (+(+s))
t << "c"
p s, t

bare = "ab"
bare_out = +(+bare)
bare_out << "c"
p bare, bare_out

minus = "ab"
minus_out = -(+minus)
p minus_out.frozen?
begin
  minus_out << "c"
rescue FrozenError
  puts "frozen"
end
p minus, minus_out

plus = "ab"
plus_out = +(-plus)
plus_out << "c"
p plus, plus_out, plus_out.frozen?

copy = "ab"
copy_out = +(copy.dup)
copy_out << "c"
p copy, copy_out

literal = +(+"lit")
literal << "c"
p literal, literal.frozen?

triple = "ab"
triple_out = (+(+(+triple)))
triple_out << "c"
p triple, triple_out

def append_nested(value)
  value << "c"
  value
end
argument = "ab"
p append_nested(+(+argument)), argument

boxed = [1, "ab"][1]
boxed_out = (+(+boxed))
boxed_out << "c"
p boxed, boxed_out

# Copying at every + would lose the original mutable String's identity.
mutable = String.new("ab")
mutable_out = (+(+(+mutable)))
mutable_out << "c"
p mutable, mutable_out, mutable.equal?(mutable_out)

# A boxed mutable String already carried as a shared handle.
boxed_source = String.new("ab")
boxed_source << ""
boxed_mutable = [1, boxed_source][1]
boxed_mutable_out = (+(+boxed_mutable))
boxed_mutable_out << "c"
p boxed_mutable, boxed_mutable_out, boxed_mutable.equal?(boxed_mutable_out)

# Parentheses can contain effects, and only the selected arm may run.
selected = String.new("ab")
selected_alias = selected
selected << ""
selected_out = +(+(puts("once"); ARGV.empty? ? selected : "other"))
selected_out_alias = selected_out
selected_out << "c"
p selected, selected_alias, selected_out

# A nil arm still calls + and raises, rather than leaving a nil handle.
begin
  nil_out = +(ARGV.empty? ? nil : selected)
  nil_alias = nil_out
  nil_out << "c"
  p nil_alias
rescue NoMethodError
  puts "nil has no unary plus"
end
