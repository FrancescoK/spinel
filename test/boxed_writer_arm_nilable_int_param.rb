# A writer whose parameter holds its nil (an Integer or nil), reached through
# a boxed receiver another class shares the name with, takes the number.
class Row
  attr_reader :status
  def initialize = @status = nil
  def status=(v)
    @status = v
  end
end

class Res
  attr_accessor :status
end

def answer(res)
  res.status = 404
  res.status
end

r = Row.new
r.status = nil
p r.status
p answer([Res.new, Row.new][0])
p answer([Res.new, Row.new][1])
