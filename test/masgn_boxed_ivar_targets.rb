# Instance variables destructured from a boxed value take its elements
class Res
  def initialize(app) = (@app = app; @body = nil)

  def run(x)
    @status, @headers, @body = @app.call(x)
    self
  end

  def parts = @body.enum_for.to_a
  def status = @status
end

app = ->(x) { x == 1 ? [200, {}, ["ok"]] : [404, {}, Enumerator.new { |y| y << "a" }] }
r = Res.new(app)
p r.run(1).parts, r.status
p r.run(2).parts, r.status

class Pair
  def set(v)
    @a, *@rest = v
    [@a, @rest]
  end
end
p Pair.new.set([1, "b", :c])
