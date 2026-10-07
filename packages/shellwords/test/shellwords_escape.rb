# Shellwords.escape makes one word safe for the Bourne shell: an empty word
# becomes '', a newline is quoted, every other character that is not a
# letter, digit or one of _-.,:+/@ gets a backslash, and a non-String is
# escaped as its to_s (#1134).
require "shellwords"

p Shellwords.escape("photo 01.jpg")
p Shellwords.escape("")
p Shellwords.escape("it's; rm -rf ~")
p Shellwords.escape("a\nb")
p Shellwords.escape("$HOME|*?[]{}<>()&`\"\\")
p Shellwords.escape("safe-word_1.2/path,+:@=%")
p Shellwords.escape("café")
p Shellwords.escape(42)
