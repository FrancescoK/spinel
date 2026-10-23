# spinel: not-cruby
# A nil separator yields the receiver; copying it into a block loses mutation.
u = +"whole"
u.each_line(nil) { |line| line << "+" }
p u
