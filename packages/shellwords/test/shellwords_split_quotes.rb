# Shellwords.split groups words as the Bourne shell does: single quotes keep
# everything literally, double quotes let a backslash escape the next
# character, a backslash outside quotes escapes the next character, and
# pieces written next to each other join into one word (#1134).
require "shellwords"

p Shellwords.split(%q(convert "photo 01.jpg" -resize 50% out\ final.jpg))
p Shellwords.split(%q(a 'b c' "d \"e\" f" g\ h))
p Shellwords.split(%q(single 'keeps \ and "' double "\$HOME \\ \x"))
p Shellwords.split(%q(one"two"'three'four))
p Shellwords.split(%q(empty '' and "" stay))
