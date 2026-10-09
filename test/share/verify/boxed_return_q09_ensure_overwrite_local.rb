class A
  def initialize(x, y) = (@x = x; @y = y)
  def other = @y
  def get
    begin
      @x
    ensure
      other
    end
  end
end
s1 = "s".dup; s2 = "t".dup; a = A.new(s1, s2)
t = a.get; t << "!"
p t, s1, s2
