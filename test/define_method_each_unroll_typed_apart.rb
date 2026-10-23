# The methods an each over literals defines with define_method are typed
# apart: each takes and stores what its own calls give it
class Echo
  [:a, :b].each { |n| define_method(n) { |v| v } }
end
p Echo.new.a(5), Echo.new.b(false)

class Options
  attr_reader :options
  def initialize(o) = @options = o
  [:limit, :null].each { |n| define_method(:"#{n}=") { |v| options[n] = v } }
  [:limit, :null].each { |n| define_method(n) { options[n] } }
end
o = Options.new({})
o.limit = 5
o.null = false
p o.options, o.limit, o.null

class Pick
  [:small, :big].each do |n|
    define_method(:"#{n}?") { |x| next x < 10 if n == :small; x >= 10 }
  end
end
p Pick.new.small?(3), Pick.new.big?(3)

Column = Struct.new(:options) do
  [:limit, :comment].each { |n| define_method(:"#{n}=") { |v| options[n] = v } }
end
c = Column.new({})
c.limit = 255
c.comment = "title"
p c.options
