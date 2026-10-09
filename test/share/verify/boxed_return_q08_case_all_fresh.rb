class A
  def initialize(x) = @x = x
  def get(k)
    case k
    when 0 then @x + "a"
    else @x + "b"
    end
  end
end
src = "s".dup; a = A.new(src)
arr = [a.get(0), a.get(1)]
arr[0] << "!"; arr[1] << "?"
p arr, src
