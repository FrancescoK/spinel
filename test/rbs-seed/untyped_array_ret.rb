# spinel: rbs-seed-check
class Rel
  def to_a
    [1, 2]
  end
end
Rel.new.to_a.each do |x|
  puts x.inspect
end
