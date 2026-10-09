S = +"s"
S << "!"
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
a = A.new
a.pick << "?"
p S
y = a.pick
p y.equal?(S), y.object_id == S.object_id
