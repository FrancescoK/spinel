# spinel: int64 -- assumes a 64-bit Integer (values or arithmetic past 2^31); not run on a 32-bit target
# An Integer Range's minmax without a block is [min, max] read off its
# endpoints, never a walk: a literal or a local Range was routed through
# to_a, which built every member first -- a range of 10**15 members could
# not finish, and an endless one said it could not convert to an array
# where CRuby says it has no maximum. A comparator block still walks.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

t("literal") { (1..10).minmax }
t("huge literal") { (1..10**15).minmax }
r = (3...10**15)
t("huge local") { r.minmax }
t("empty") { (5..1).minmax }
t("excl point") { (1...1).minmax }
t("endless") { (1..).minmax }
t("beginless") { (..5).minmax }
t("step") { 10.downto(1).minmax }
t("block") { (1..4).minmax { |a, b| b <=> a } }
def m(x) = x.minmax
t("param") { m(2..7) }
