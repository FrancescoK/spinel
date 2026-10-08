# spinel: rbs-seed-check
class YuResult
  def to_a
    [[1, 2]]
  end
end
class YuRel
  def group_count
    { "x" => 1 }
  end
end
class YuC
  def monthly
    puts yield.to_a.inspect
  end
  def index
    monthly { YuRel.new.group_count }
    monthly { YuResult.new }
  end
end
YuC.new.index
