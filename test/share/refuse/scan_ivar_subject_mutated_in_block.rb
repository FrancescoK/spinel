# The same with an instance variable as the subject, changed by a mutator
# other than `<<`.
class Tokens
  def initialize
    @s = +"abc"
    @acc = []
  end

  def run
    @s.scan(/./) { |m| @acc << m; m << "!"; @s.concat("z") if m == "a!" }
    @acc
  end
end
p Tokens.new.run
