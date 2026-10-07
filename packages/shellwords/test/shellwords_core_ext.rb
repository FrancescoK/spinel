# require "shellwords" also gives String#shellsplit, String#shellescape and
# Array#shelljoin, and the module's shellwords, shellsplit, shellescape and
# shelljoin names; each answers what the matching module function does
# (#1134).
require "shellwords"

p "x 'y z'".shellsplit
p "x y".shellescape
p ["a b", "c"].shelljoin
p Shellwords.shellwords("a b"), Shellwords.shellsplit("c d")
p Shellwords.shellescape("e f"), Shellwords.shelljoin(["g h"])
