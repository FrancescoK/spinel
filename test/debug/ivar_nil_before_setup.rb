# Built with -g (cli-opts-test): a debug build raises NoMethodError for a
# call through an ivar a setup method has not assigned yet, as CRuby does,
# where the release build dereferences the NULL slot (#5960).
class Engine
  def run = "running"
end

class Box
  def setup
    @engine = Engine.new
    @name = +"box"
    @items = [1, 2]
    @store = {}
  end

  def go = @engine.run
  def label = @name.upcase
  def first = @items.first
  def put(k, v) = @store[k] = v
end

b = Box.new
[:go, :label, :first].each do |m|
  begin
    p b.send(m)
  rescue NoMethodError => e
    puts "NoMethodError: #{e.message}"
  end
end
begin
  b.put(:a, 1)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
b.setup
p [b.go, b.label, b.first, b.put(:a, 1)]
