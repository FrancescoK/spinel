class A
  def initialize(x) = (@x = x; @n = 0)
  def get
    begin
      @x
    ensure
      @n += 1
    end
  end
end
src = "s".dup; a = A.new(src)
t = a.get; t << "!"
p t, src
