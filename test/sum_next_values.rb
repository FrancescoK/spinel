# spinel: share
# spinel: gc-minor
# A next value contributes to the sum just as the block's tail does.
p [1, 2].sum { |x| next 0.5 if x == 1; 1 }
p (1..2).sum { |x| next 0.5 if x == 1; 1 }
p [1, 2].sum(0.0) { |x| next 0.5 if x == 1; 1 }
p [].sum { |x| next 0.5 if x == 1; 1 }
p [1, 2].sum { |x| [x].each { next 0.25 }; x }
begin
  p [1, 2].sum { |x| next if x == 1; 1 }
rescue TypeError => e
  puts e.class
end

# A next value can also reach a user's coerce even with a numeric tail.
class SumNextCoerce
  def coerce(n)
    [n, 0.5]
  end
end
p [1, 2].sum { |x| next SumNextCoerce.new if x == 1; 1 }
