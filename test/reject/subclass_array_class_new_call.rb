# `Class.new(Array)` without a block makes its class at run time, and no
# class of the program's own stands for it, so it is refused where it is
# written (#7449); `class Points < Array` and the block form are supported.
Points = Class.new(Array)

pts = Points.new
pts << 1
p pts, pts.class
