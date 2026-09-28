# ARGF.gets(chomp: true) answers the line without its "\n" or "\r\n", as
# CRuby does, and evaluates the keyword's value; chomp: false keeps the
# ending, and a last line with no newline keeps its "\r".
p ARGF.gets(chomp: true)
p ARGF.gets(chomp: false)
c = [true, 0][0]
p ARGF.gets(chomp: c)
p ARGF.gets
p ARGF.gets(chomp: true)
p ARGF.gets(chomp: true)
p ARGF.gets(chomp: (puts "flag"; true))
