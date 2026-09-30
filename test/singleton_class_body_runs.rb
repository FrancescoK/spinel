# Statements in a `class << self` / `class << Const` body run where the
# body stands, in order with the surrounding class body.

class A
  @v = 10
  class << self
    p 5
    x = 4
    puts "x is #{x}"
    @v = 99
    attr_reader :v
    def one = 1
    [1, 2].each { |i| print i, "\n" }
  end
  p 6
end

module M
  class << self
    puts "module body"
    def two = 2
  end
end

class << A
  puts "reopened"
  def three = 3
end

p A.v
p A.one
p M.two
p A.three
