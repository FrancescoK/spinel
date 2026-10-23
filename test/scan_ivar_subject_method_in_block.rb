# A method the block calls changes the instance variable the scan walks.
class H
  def initialize; @s = +"ab"; @acc = []; end
  def bump = @s << "z"
  def run
    @s.scan(/./) { |m| @acc << m; m << "*"; bump if @acc.size == 1 }
  rescue RuntimeError => e
    p e.message
  end
  def show = p(@acc, @s)
end
h = H.new; h.run; h.show
