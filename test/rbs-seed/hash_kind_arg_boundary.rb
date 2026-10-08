# An RBS seed pins a parameter to Hash[Symbol, untyped] while the caller's own
# inference widens its value to the boxed-key hash -- two different C structs,
# so the assignment was not one C accepts. The argument converts at the
# boundary now, which is where the seed's claim about the value is checked.
# spinel: rbs-seed-check
module SVG
  class T
    def initialize(o)
      @o = o
    end
    def title
      @o[:title].to_s
    end
    def size
      @o.size
    end
  end
end

box = [1, "x", { title: "Votes", scale: 10000 }]
opts = box[2]

defaults = { width: 800, title: "G", flag: false }
t = SVG::T.new(defaults.merge(opts))
puts t.title
puts t.size
puts SVG::T.new({ title: "plain" }).title
puts SVG::T.new(defaults).title
