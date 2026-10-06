# The `chomp:` keyword on String#lines and #each_line and on IO#gets,
# #readline and #readlines, with a literal true, false, nil, a non-boolean
# literal, and a value known only at run time. CRuby generated the
# expectations.
p "ab\n".each_line(chomp: 1).to_a
p "ab\n".each_line(chomp: nil).to_a
p "ab\ncd\n".lines(chomp: 1)
p "ab\ncd\n".lines(chomp: false)
p "ab\ncd\n".lines("\n", chomp: :yes)
p "ab\ncd\n".lines("\n", chomp: nil)
f = false
t = "truthy"
p "ab\n".lines(chomp: f)
p "ab\n".lines(chomp: t)
p "ab\n".each_line(chomp: t).to_a
File.write("/tmp/spinel_keyword_flag_test_#{Process.pid}.txt", "a\nb\nc\n")
File.open("/tmp/spinel_keyword_flag_test_#{Process.pid}.txt") do |fh|
  p fh.gets(chomp: "yes")
  p fh.readline(chomp: nil)
  p fh.gets(chomp: t)
end
File.delete("/tmp/spinel_keyword_flag_test_#{Process.pid}.txt")
File.write("/tmp/spinel_keyword_flag_test2_#{Process.pid}.txt", "a\nb\n")
p File.readlines("/tmp/spinel_keyword_flag_test2_#{Process.pid}.txt", chomp: 1)
p File.readlines("/tmp/spinel_keyword_flag_test2_#{Process.pid}.txt", chomp: f)
p File.readlines("/tmp/spinel_keyword_flag_test2_#{Process.pid}.txt", chomp: t)
File.open("/tmp/spinel_keyword_flag_test2_#{Process.pid}.txt") { |fh| p fh.readlines(chomp: :y) }
File.open("/tmp/spinel_keyword_flag_test2_#{Process.pid}.txt") { |fh| p fh.readlines(chomp: t) }
File.delete("/tmp/spinel_keyword_flag_test2_#{Process.pid}.txt")
