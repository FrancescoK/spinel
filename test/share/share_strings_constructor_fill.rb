# A fill constructor keeps the String held by its argument, including
# readers and parameters whose semantic type remains String.
class ConstructorFill
  attr_accessor :value
  Member = Struct.new(:value)

  def run
    self.value = "aab#{ARGV.size}"
    t = Array.new(2, self.value)[1]
    p self.value.equal?(t), self.value.frozen?, t.frozen?
    value.replace("zz")
    p value, t
    u = ::Array.new(2, self.value)[0]
    u << "."
    p value, t, u
    t << "!"
    p value, t

    o = Member.new("fixed")
    a = Array.new(2, o.value)
    p o.value.equal?(a[0]), a[0].equal?(a[1]), a[1].frozen?
    begin
      a[1].upcase!
    rescue FrozenError => e
      p e.class
    end
    p o.value, a
    fresh = Array.new(2, Member.new(+"fresh").value)
    fresh[0] << "!"
    p fresh, fresh[0].equal?(fresh[1])

    parameter("aab#{ARGV.size}")
    ["block#{ARGV.size}"].each do |s|
      u = Array.new(2, s)[0]
      s.insert(0, "w")
      p s, u, s.equal?(u)
    end
    s = "capture#{ARGV.size}"
    f = lambda do
      a = Array.new(2, s)
      a[0] << "?"
      p s, a, s.equal?(a[1])
    end
    f.call
  end

  def parameter(s)
    a = Array.new(2, s)
    s.insert(0, "w")
    p s, a, s.equal?(a[1])
    a[0].upcase!
    p s, a
  end
end
ConstructorFill.new.run
