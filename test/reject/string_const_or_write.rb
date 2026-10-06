# `X ||= v` binds the constant, and a later append through X changes its
# String. The append was lost and X stayed "abc": refused, not compiled
# wrong.
X ||= +"abc"
X << "!"
p X
