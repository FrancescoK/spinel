# The declaration covers the block parameter's own reads only. Another shared
# String inside the block (`freeze`, whose result is bound) is frozen and
# answered as its handle, so nothing is reported for it either.
keep = +"k"
same = keep
same << "!"
words = %w[a b].map(&:dup)
frozen = nil
words.map! { |w| frozen = keep.freeze; w }
p words, frozen.equal?(same)
