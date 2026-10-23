# The two String representations refused this program; with one it answers as CRuby.
# A nil separator yields the receiver; copying it into a block loses mutation.
u = +"whole"
u.each_line(nil) { |line| line << "+" }
p u
