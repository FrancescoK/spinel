# spinel: reject-share
# A match `scan` hands its block is kept and then appended to. `scan` binds
# each match as a plain String, which the shared handle the block needs
# cannot take: refused, where the C used not to build.
acc = []
"a1b2".scan(/[a-z]/) { |m| acc << m; m << "*" }
p acc
