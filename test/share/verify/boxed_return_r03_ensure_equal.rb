S = +"s"
class A
  def initialize = @n = 0
  def pick
    begin
      S
    ensure
      @n += 1
    end
  end
end
p A.new.pick.equal?(S)
