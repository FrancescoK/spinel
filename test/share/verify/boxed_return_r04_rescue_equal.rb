S = +"s"
class A
  def pick(k)
    begin
      raise "x" if k == 1
      S
    rescue
      S + "r"
    end
  end
end
a = A.new
p a.pick(0).equal?(S), a.pick(1).equal?(S)
