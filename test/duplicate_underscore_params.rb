# Ruby lets an underscore-prefixed parameter name repeat in one list; each
# repetition binds its own slot (the body reads the first). They became two
# declarations of one C local and the build failed.
cb = proc { |_, _, offset| offset * 2 }
p cb.call(1, 2, 21)
def pick(_, _, x) = x
p pick(:a, :b, :c)
p [[1, 2, 3]].map { |_, _, z| z }
