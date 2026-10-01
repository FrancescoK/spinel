# `redo` re-runs a block's body without binding its parameters again. The
# block of `inject` is walked by an emitter that places no label for it,
# and the redo compiled to a `continue`, which left the block as `next`
# does: CRuby answers 11, Spinel answered 2. It is refused at this line
# instead (test/redo_block_keeps_writes.rb has the iterators that run it).
done = false
p([1, 2].inject(0) { |s, x| unless done; done = true; x = 9; redo; end; s + x })
