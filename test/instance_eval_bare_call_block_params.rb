# A receiverless call with a block inside an instance_eval/exec block goes
# to the receiver's method, and that method's block.call / yield types the
# block's parameters: they were left untyped, and a call on one raised
# NoMethodError.

class Mapper
  def initialize; @s = Array.new(0) { "" }; end
  def res(name, &block)
    @s << "res #{name}"
    block.call(self) unless block.nil?
    nil
  end
  def scope(name)
    @s << "scope #{name}"
    yield self, name.to_s.length
    nil
  end
  def s = @s
end

m = Mapper.new
m.instance_eval do
  res(:x) { |a| a.res :y }
  res(:z) do |a|
    a.res(:w) { |b| b.res :v }
  end
  scope(:api) { |a, n| a.res "#{n}" }
end
m.instance_exec(:q) do |nm|
  res(nm) { |a| a.res :r }
end
puts m.s

# a bare `res` in Router's own method is Router's; inside the block it is Mapper's
class Router
  def res(name) = "router #{name}"
  def routes
    m2 = Mapper.new
    m2.instance_eval do
      res(:photos) { |a| a.res :comments }
    end
    m2.s
  end
end
puts Router.new.routes
puts Router.new.res(:n)
