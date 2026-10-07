# Shellwords.join escapes each word and joins them with a space, so
# splitting the result gives the same words back; a non-String word is
# joined as its to_s (#1134).
require "shellwords"

words = ["git", "commit", "-m", "it works", "", "a'b", "line\nbreak"]
line = Shellwords.join(words)
p line
p Shellwords.split(line) == words
p Shellwords.join(["n", 1, :sym])
p Shellwords.join([])
