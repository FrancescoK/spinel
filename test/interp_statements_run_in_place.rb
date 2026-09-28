# Statements and an assignment inside `#{}` run where the interpolation
# stands, after everything to their left: they were hoisted ahead of the
# whole expression, so a left operand read the variable's new value.
x = "a"
puts "#{x}" + "#{x = "b"}"
y = "a"
puts "#{y}-#{y = "c"; y}-#{y}"
_cap = nil
s = "<summary>#{_cap = ""; _cap = _cap + "icon"; _cap}</summary>" + "<div>#{_cap = "list"; _cap}</div>"
puts s
n = 1
puts "#{n}#{n += 1}#{n}"
buf = String.new
z = "p"
buf << "#{z}" << "#{z = "q"}#{z}"
buf << "!"
puts buf
def pair(a, b) = "#{a}|#{b}"
w = 1
puts pair("#{w}", "#{w = 2; w * 10}")
