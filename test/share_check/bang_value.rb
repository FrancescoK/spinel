# A bang on a boxed receiver used as a value answers the receiver's own box,
# so `||` keeps `words[0]` itself, and the bytes the bang read and wrote back
# are no copy (the check reports nothing).
words = [+" a ", +"b"]
first = words[0]
words.map! { |x| x.strip! || x }
first << "!"
p words, first
