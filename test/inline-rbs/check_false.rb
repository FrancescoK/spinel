# spinel: not-cruby -- a false inline annotation aborts under -DSP_RBS_CHECK
class Row
  def initialize
    @n = nil #: Integer?
  end

  def n=(v)
    @n = v
  end

  def n
    @n
  end
end

vals = [1, "two", 3.5]
r = Row.new
r.n = vals[1]
p r.n
