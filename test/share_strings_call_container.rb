# The Array a call answers (split, keys, lines) binds its elements to the
# block that iterates it; Strings appended from there into a shared String
# reach it, as tools/spin.rb's source scan does.
$seen = +""
out = +""
alias_out = out
"a.c\nb.h\nc.c".split("\n").each do |f|
  next if f.end_with?(".h")
  $seen += f + ";"
  out << f << ","
end
h = { "x" => 1, "y" => 2 }
h.keys.each { |k| out << k }
"l1\nl2\n".lines.each { |l| out << l.chomp }
p out, alias_out, $seen
