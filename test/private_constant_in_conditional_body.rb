# private_constant inside a conditional in a module body (tzinfo's
# string_deduper.rb defines the class it makes private in one branch)
# declares as it does at the body's top level.
module TZ
  class Ded
    def dedupe(s) = "plain:" + s
  end
  fast = [1, 2].sum == 3
  if fast
    class UnaryDed < Ded
      def dedupe(s) = "unary:" + s
    end
    private_constant :UnaryDed
    def self.make = UnaryDed.new
  else
    def self.make = Ded.new
  end
  unless fast
    public_constant :Ded
  end
end
p TZ.make.dedupe("x")
