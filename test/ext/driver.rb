# Drives the generated CRuby extension (ext-cruby-test); output pinned in
# expected_cruby.
# GC stress before the extension first allocates: a collection then runs
# inside every argument conversion, not only on a large enough input.
ENV["SPINEL_GC_STRESS"] = "1"
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "extk"
p ExtKernel.triple(5)
p ExtKernel.shout("hey")
p ExtKernel.total([1, 2, 3])
begin
  ExtKernel.must_pos(-2)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
begin
  ExtKernel.triple("x")
rescue TypeError
  puts "TypeError"
end
p ExtKernel.must_pos(6)
left = Array.new(400) { |i| "left-#{i}" }
right = Array.new(400) { |i| "right-#{i}" }
want = left.sum(&:length) + right.sum(&:length)
p 20.times.all? { ExtKernel.pair_sum(left, right) == want }
# A conversion that raises after an earlier argument was rooted -- the second
# argument, or an element inside its helper -- leaves the root stack as it
# found it: the calls after it collect and still answer.
def at_depth(n, &b) = n.zero? ? b.call : at_depth(n - 1, &b)
p(20.times.all? do |i|
  begin; ExtKernel.pair_sum(left, 1); rescue TypeError; end
  begin; ExtKernel.pair_sum(left, ["x", 2]); rescue TypeError; end
  at_depth(i % 7) { ExtKernel.pair_sum(left, right) } == want
end)
# NOTE: TOPLEVEL_NOTE deliberately absent -- the kernel's toplevel runs on
# the SPINEL side at init; nothing but the entry methods exists on the host.
