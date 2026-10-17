# Each StringScanner reader answers a new String, as CRuby's do: the scanner
# keeps its last match as an offset and a length, so changing what scan
# answered changes neither #matched nor #post_match, two #matched answers
# are two Strings, and an empty #rest is a String of its own.
require "strscan"
sc = StringScanner.new(+"abc def")
w = sc.scan(/\w+/)
w << "!"
p w, sc.matched, sc.post_match
m = sc.matched
m << "?"
p m, sc.matched, m.equal?(sc.matched)
sc.scan(/ /)
g = sc.getch
g << "#"
p g, sc.matched, sc.pre_match
sc.terminate
r = sc.rest
r << "y"
p r, sc.rest
