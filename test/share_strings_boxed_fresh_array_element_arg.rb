def show(r)
  puts "#{r} #{r.length}"
end

x = [1, "ab\ncd,ef"][1]
show(x.lines[0])
show(x.split(",")[1])
show(x.chars[0])
show(x.scan(/[a-z]+/)[1])
show(x.lines.first)
show(x.split(",").last)
b = x.dup
b.upcase!
show(b)
