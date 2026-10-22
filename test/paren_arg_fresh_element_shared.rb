# A new String taken from an Array a String builds (`x.lines[0]`, `.first`,
# `.last`) and handed to a method inside parentheses after another
# statement, `show((n += 1; x.lines[0]))`, is handed on as it is without the
# parentheses, in a program where another String is shared and changed in
# place.
def show(r)
  puts "#{r} #{r.length}"
end

x = [1, "ab\ncd,ef"][1]
n = 0
show((n += 1; x.lines[0]))
show((n += 1; x.split(",")[1]))
show((n += 1; x.chars[0]))
show((n += 1; x.scan(/[a-z]+/)[1]))
show((n += 1; x.lines.first))
show((n += 1; x.split(",").last))
b = x.dup
b.upcase!
show(b)
p n
