# The declaration covers the block parameter's own reads only: the copy made
# of another shared String inside the block (`freeze`, whose result is bound)
# is still reported.
keep = +"k"
same = keep
same << "!"
words = %w[a b].map(&:dup)
frozen = nil
words.map! { |w| frozen = keep.freeze; w }
p words, frozen.equal?(same)
