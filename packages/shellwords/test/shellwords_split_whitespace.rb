# Shellwords.split separates words on any run of spaces, tabs and newlines,
# ignores it at both ends, answers [] for an empty line, and keeps a
# multibyte word whole (#1134).
require "shellwords"

p Shellwords.split("  leading\tand\ntrailing  ")
p Shellwords.split("")
p Shellwords.split("   ")
p Shellwords.split("café 'olá mundo'")
