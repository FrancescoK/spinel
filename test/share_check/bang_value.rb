# A bang used as a value answers the transformed bytes, and `||` boxes them
# into a new String that is not `words[0]` (a wrong answer under
# --share-strings, whose report is what this records).
words = [+" a ", +"b"]
first = words[0]
words.map! { |x| x.strip! || x }
first << "!"
p words, first
