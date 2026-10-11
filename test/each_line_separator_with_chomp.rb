def split_on(s, sep, ch)
  r = []
  s.each_line(sep, chomp: ch) { |l| r << l }
  r
end

r = []
"a\0b\0c".each_line("\0", chomp: true) { |l| r << l }
p r
r = []
"a--b--c".each_line("--", chomp: false) { |l| r << l }
p r
r = []
"a\n\nb\n\n\nc".each_line("", chomp: true) { |l| r << l }
p r
r = []
"a::b::c".lines("::", chomp: true) { |l| r << l.upcase }
p r
p split_on("axbxc", "x", true)
p split_on("axbxc", "x", false)
p split_on("a\0\0b\0\0c", "\0\0", [true, nil][0])
p "a\0b\0c".each_line("\0", chomp: true).to_a
p "axbxc".each_line("x", chomp: false).to_a
p split_on("axbxc", "x", nil).size
