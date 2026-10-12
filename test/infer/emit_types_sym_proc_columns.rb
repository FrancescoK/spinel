# The nodes after an `&:to_s` on its line keep the columns they were
# written at (`s` of the second block at column 34), and the block the
# `&:to_s` stands for is placed at it (column 19).
words = [1, 2].map(&:to_s).map { |s| s + "!" }
p words
