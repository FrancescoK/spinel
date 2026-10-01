# `redo` re-runs a block's body without binding its parameters again. The
# block of `map.with_index` is walked by an emitter that places no label for
# it, and the redo compiled to a `continue`, which left the block as `next`
# does: CRuby answers [9, 3], Spinel answered [3]. It is refused at this
# line instead (test/redo_block_keeps_writes.rb and
# test/builtin_iter_step_frame.rb have the iterators that run it).
done = false
p([1, 2].map.with_index { |x, i| unless done; done = true; x = 9; redo; end; x + i })
