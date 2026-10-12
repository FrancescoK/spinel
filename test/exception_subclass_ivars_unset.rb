# An exception class of the program's, built without an initialize of its
# own, starts its ivars unset and keeps what they hold through a collection.
module App
  class Failure < StandardError
    attr_accessor :count, :label, :tags, :ratio, :kind, :data
    def fill(i)
      @count = i
      @label = "label-#{i}" * 2
      @tags = ["t#{i}", "u#{i}"]
      @ratio = i / 4.0
      @kind = :k
      @data = i.even? ? i : "odd#{i}"
    end
  end
  class Deeper < Failure
    attr_accessor :extra
  end
end

e = App::Failure.new("m")
p [e.count, e.label, e.tags, e.ratio, e.kind, e.data]
e.count ||= 5
e.label ||= "dflt"
p [e.count, e.label]

kept = []
40.times do |i|
  x = i.even? ? App::Failure.new("f#{i}") : App::Deeper.new("d#{i}")
  x.fill(i)
  kept << x
end
junk = []
3000.times { |i| junk << "junk#{i}" * 3 }
GC.start
p kept.map(&:label).uniq.size
p kept[7].label, kept[7].tags, kept[8].data, kept[9].data, kept[9].ratio
p kept.map(&:message).last

begin
  raise App::Deeper, "boom"
rescue App::Failure => r
  p [r.message, r.count, r.data]
end
d = App::Deeper.new
p [d.message, d.extra]
d.fill(3)
c = d.dup
p [c.label, c.tags, c.count]

# a subclass with more ivars, raised by class and rescued as its parent,
# is its own whole struct
caught = []
60.times do |i|
  begin
    raise App::Deeper, "deep#{i}"
  rescue App::Failure => r
    r.fill(i)
    caught << r
  end
  200.times { |j| "g#{j}" * 4 }
end
GC.start
p caught.size, caught.last.message, caught.last.class, caught[3].tags, caught[5].label

# one variable bound in two rescue arms of different classes
class OneErr < StandardError; attr_accessor :x; end
class TwoErr < StandardError; attr_accessor :y; end
begin; raise OneErr, "one"; rescue OneErr => e2; p [e2.message, e2.x]; end
begin; raise TwoErr, "two"; rescue TwoErr => e2; p [e2.message, e2.y]; end
