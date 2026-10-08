# A boxed block parameter keeps the handle it was handed when a Struct's
# member array stores it, including through the generated Enumerable helper.
class StructArray
  Member = Struct.new(:value)
  attr_accessor :value

  def run
    [+"aabc"].each do |s|
      t = Member.new(s).to_a[0]
      p s.equal?(t)
      t << "x"
      p s, t, s.equal?(t)
      s.upcase!
      p s, t
    end
    ["fixed"].each do |s|
      t = Member.new(s).to_a[0]
      p s.frozen?, t.frozen?
      begin
        s.setbyte(0, 65)
      rescue FrozenError => e
        p e.class
      end
      p s, t
    end
    self.value = "attr#{ARGV.size}"
    a = Member.new(value).to_a
    a[0] << "!"
    p value, a
    parameter("param#{ARGV.size}")
    s = "local#{ARGV.size}"
    o = Member.new(s)
    a = o.values
    s << "?"
    p s, a, o.to_a, o.deconstruct
  end

  def parameter(s)
    a = Member.new(s).to_a
    s.replace("changed")
    p s, a
  end
end
StructArray.new.run
