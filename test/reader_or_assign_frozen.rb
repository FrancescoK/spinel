# Reading a mutable String slot preserves its frozen state in an ordinary
# value snapshot, including the value stored by ||=. The default build does
# not need another shared handle for that snapshot.
# spinel: gc-minor
# spinel: share
class FrozenReader
  attr_accessor :text

  def custom = @text

  def check
    t = nil
    t ||= self.text
    u = nil
    u ||= text
    v = nil
    v ||= instance_variable_get(:@text)
    w = nil
    w ||= custom
    p [self.text.frozen?, t.frozen?, u.frozen?, v.frozen?, w.frozen?]
    p [t.bytes, u.bytes, v.bytes, w.bytes]
    begin
      t.squeeze!
      puts "mutable snapshot"
    rescue => e
      p e.class
    end
    begin
      self.text.squeeze!
      puts "mutable"
    rescue => e
      p e.class
    end
    p [self.text.frozen?, t.frozen?]
    p [self.text, t]
  end

  def run
    self.text = "aabc"
    check
    self.text = "a\0ab".b.freeze
    check
    self.text = +"abcd"
    check
    self.text = nil
    t = nil
    t ||= self.text
    p t
  end
end

FrozenReader.new.run

class OtherFrozenReader
  attr_reader :text
  def initialize
    @text = +"peer"
    @text << "!"
    @text.freeze
  end
end

def choose_reader(flag, left, right)
  flag ? left : right
end

left = FrozenReader.new
left.text = "reader"
right = OtherFrozenReader.new
p choose_reader(true, left, right).text.frozen?
p choose_reader(false, left, right).text.frozen?
