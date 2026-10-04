# A %(...) command argument is a literal, so a <<WORD in its text opens no
# heredoc, and the &:sym rewrites after it still run (#7194).
puts %(git commit -F - <<EOF)
p [1, 2].map(&:to_s)
x = 7
y = 3
p x % y
p x %y
p(x %(y))
def show(s) = puts(s)
show %(a <<B b)
p %w[a b].map(&:upcase)
