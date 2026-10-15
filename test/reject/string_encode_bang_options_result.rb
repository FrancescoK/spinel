# encode! answers its receiver with options too (here it retags "hello"
# in place). The retained result is a copy today, so an append through it
# would not reach s: refused.
s = +"hello"
r = s.encode!("BINARY", undef: :replace)
r << "!"
p s
