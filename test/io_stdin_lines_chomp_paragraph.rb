# `$stdin.gets` and `$stdin.each_line` read paragraphs and chomp "\r\n" as a File does.
p $stdin.gets("", chomp: true)
p $stdin.gets("")
p $stdin.gets(chomp: true)
a = []
$stdin.each_line(chomp: true) { |l| a << l }
p a
