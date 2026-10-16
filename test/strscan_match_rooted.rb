# spinel: gc-stress
# StringScanner holds the Strings a match makes. A scanner that has lived
# through a collection is old, and the last match it records afterwards
# went in with no write barrier, so the next minor collection freed it;
# scan_until held the text it answers unrooted while it made the match,
# scan and check the same when a \K moves the match, and every scanning
# method its own scanner while it allocated. Under SPINEL_GC_STRESS=2 each
# was read back freed.
require "strscan"
sc = StringScanner.new("key = value; next = 2")
p sc.scan(/\w+/), sc.matched, sc.pre_match
p sc.scan_until(/=\s*/), sc.matched, sc[0]
p sc.check_until(/;/), sc.matched
p sc.skip(/\w+/), sc.matched, sc.getch, sc.matched
p sc.match?(/\s*\w+/), sc.matched, sc.exist?(/2/), sc.matched
p sc.skip_until(/=/), sc.matched, sc.rest
k = StringScanner.new("ab12")
p k.scan(/ab\K\d/), k.matched, k.check(/2\K/), k.matched.size
p StringScanner.new(+"xyz").scan(/x\Ky/), StringScanner.new(+"xyz").scan_until(/y/)
p StringScanner.new("ab").exist?(/b/), StringScanner.new("€x").getch
