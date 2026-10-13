# spinel: gc-stress
# A runtime helper that builds its answer from new Strings holds that
# answer, and the object it reads, across the allocations it makes. split
# and File#readlines held their Array unrooted while they allocated each
# element, gsub with a String pattern and a Hash its answer while it set
# `$~`, and named_captures and deconstruct_keys a MatchData nothing else
# held: under SPINEL_GC_STRESS=2 each was collected and read back freed.
require "tmpdir"
def words(s) = s.split(/,\s*/)
p words("a, b,c, d")
p "x1y22z333".split(/\d+/, 2), "x1y22z333".split(/(\d)/)
p "aXbXc".split(/x/i, -1).map(&:upcase)
s = +"one-two-three"
p s.gsub("-", "-" => "+"), $~[0]
p s.gsub("t", {"t" => "T"}).size, $~.pre_match.size
def md(s) = s.match(/(?<a>.)(?<b>.)/)
p md("xy").named_captures, md("pq").named_captures(symbolize_names: true)
p md("uv").deconstruct_keys([:b]), md("mn").deconstruct_keys(nil)
path = File.join(Dir.tmpdir, "spinel_helper_results_#{Process.pid}.txt")
File.write(path, "one\ntwo\nthree\n")
f = File.open(path)
p f.readlines, File.new(path).readlines.size, File.new(path).gets
f.close
File.delete(path)
