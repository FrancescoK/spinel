module M
  K = Class.new { Y = 1; def y = Y }
end
class D; Y = 5; def y = Y; end
p M::K.new.y, Y, D.new.y
