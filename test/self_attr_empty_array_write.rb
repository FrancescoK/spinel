class Fail; end
class Skip2 < Fail; end
class Res
  attr_accessor :failure
  def initialize(f) = @failure = f
end
class Rep
  attr_accessor :results
  def initialize = self.results = []
  def record(r) = (results << r)
  def report
    agg = results.group_by { |r| r.failure.class }
    agg.default = []
    p [agg[Fail].size, agg[Skip2].size, agg[NilClass].size]
  end
end
rep = Rep.new
rep.report
rep.record(Res.new(nil))
rep.record(Res.new(Skip2.new))
rep.record(Res.new(Fail.new))
rep.report
