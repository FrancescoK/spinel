# A top level past 64 KB of C with a setjmp in it compiles to parts, each a
# C function of its own that the body calls in turn, so gcc's cost for a
# function holding many setjmps stays per part. A local keeps one storage
# across the parts: one read in several moves to file scope, one used in a
# single part stays declared there, one a BEGIN block shares stays in the
# body. The locals here cover the kinds a declaration takes (Integer, Float,
# String, Symbol, Range, Array, Hash, an object, a boxed value, a captured
# cell, a local written in a rescue and read after it), and the rescues and
# the allocations between them keep the collector and the setjmps busy.
# spinel: gc-minor
BEGIN { begun = 7 }

class Box
  attr_reader :v
  def initialize(v) = (@v = v)
  def inspect = "Box(#{@v})"
end

def boom(n) = raise(ArgumentError, "bad #{n}")

count = 0
sum = 0.5
text = +"t"
sym = :a
range = (1..3)
list = []
table = {}
box = Box.new(0)
any = 1
bump = -> { count += 1 }
last = nil
puts "begun #{begun}"

begin; boom(1); rescue => e; last = e.message; list << last; end
begin; boom(2); rescue => e; text << "#{e.message.size}"; end
begin; boom(3); rescue ArgumentError => e; table[:three] = e.message; end
begin; boom(4); rescue => e; sum += 1.25; bump.call; end
begin; boom(5); rescue => e; sym = :b; any = "any #{e.message}"; end
begin; boom(6); rescue => e; box = Box.new(6); list << box.inspect; end
begin; boom(7); rescue => e; range = (range.first + 1)..(range.last + 1); end
begin; boom(8); rescue => e; list << "#{e.class}: #{e.message}"; bump.call; end
begin; boom(9); rescue => e; table["nine"] = [e.message, e.message.upcase]; end
begin; boom(10); rescue => e; text << e.message[-2..]; count += 10; end
here = [count, sum, text.dup, sym, range.to_a, list.size]
puts here.inspect
begin; boom(11); rescue => e; list << e.message.split.reverse.join("-"); end
begin; boom(12); rescue => e; sum *= 2; bump.call; end
begin; boom(13); rescue => e; table[:thirteen] = { m: e.message, n: 13 }; end
begin; boom(14); rescue => e; any = [any, 14]; end
begin; boom(15); rescue => e; box = Box.new(box.v + 15); end
begin; boom(16); rescue => e; text = text + "|#{e.message}"; end
begin; boom(17); rescue => e; list << (1..17).select(&:even?).sum; end
begin; boom(18); rescue => e; range = range.first..(range.last * 2); bump.call; end
begin; boom(19); rescue => e; table[19] = e.message.chars.first(3).join; end
begin; boom(20); rescue => e; last = "#{last} then #{e.message}"; end
mid = list.map(&:to_s).map(&:size)
puts mid.inspect
begin; boom(21); rescue => e; list << e.message * 2; end
begin; boom(22); rescue => e; sum -= 0.25; count += 22; end
begin; boom(23); rescue => e; table[:twentythree] = e.message.tr("a", "A"); end
begin; boom(24); rescue => e; sym = :"c#{count}"; end
begin; boom(25); rescue => e; box = Box.new([box.v, 25]); bump.call; end
begin; boom(26); rescue => e; text << "#{text.size}"; end
begin; boom(27); rescue => e; any = { any: any }; end
begin; boom(28); rescue => e; list << e.message.sub("bad", "good"); end
begin; boom(29); rescue => e; range = (range.first * 2)..range.last; end
begin; boom(30); rescue => e; table["thirty"] = [30, 3.0, "30", :thirty]; bump.call; end
only = []
30.times { |i| only << "o#{i}" if i % 7 == 0 }
puts only.inspect
begin; boom(31); rescue => e; list << e.message.reverse; end
begin; boom(32); rescue => e; sum = sum.round(2) + 32; end
begin; boom(33); rescue => e; table[:thirtythree] = e.message.bytes.sum; end
begin; boom(34); rescue => e; text << e.message.upcase; count += 34; end
begin; boom(35); rescue => e; box = Box.new("#{box.inspect} 35"); end
begin; boom(36); rescue => e; list << [e.message, 36].inspect; bump.call; end
begin; boom(37); rescue => e; any = any.to_s.size; end
begin; boom(38); rescue => e; last = e.message.center(12, "*"); end
begin; boom(39); rescue => e; table[39.0] = e.message.length; end
begin; boom(40); rescue => e; range = range.first..(range.last + 40); bump.call; end
begin; boom(41); rescue => e; list << e.message.each_char.to_a.last; end
begin; boom(42); rescue => e; sum += 0.125; text << "!"; end
begin; boom(43); rescue => e; table[:fortythree] = e.message.split.map(&:size); end
begin; boom(44); rescue => e; sym = sym.to_s.succ.to_sym; count += 44; end
begin; boom(45); rescue => e; list << format("%s/%d", e.message, 45); end
begin; boom(46); rescue => e; table[:fortysix] = e.message.scan(/\d/).join; end
begin; boom(47); rescue => e; list << e.message.ljust(9, "."); bump.call; end
begin; boom(48); rescue => e; any = [any, e.message].flatten.size; end
begin; boom(49); rescue => e; box = Box.new(e.message.count("b")); end
begin; boom(50); rescue => e; text << e.message.delete(" "); count += 50; end
begin; boom(51); rescue => e; sum /= 2; range = range.first..(range.last - 1); end
begin; boom(52); rescue => e; list << e.message.start_with?("bad"); end
begin; boom(53); rescue => e; table[:fiftythree] = [e.message] * 2; end
puts [count, sum, text, sym, range, list.size, table.size, box, any, last].inspect
puts list.inspect
puts table.inspect
