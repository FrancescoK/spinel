S = +"s"
class A
  def pick(k)
    case k
    when 0 then S
    else S + "c"
    end
  end
end
a = A.new
p a.pick(0).equal?(S), a.pick(1).equal?(S)
