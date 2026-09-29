class C
  def pair = [[1, 2], 3]
  def go
    (@a, @b), c = pair
    p [@a, @b, c]
  end
end
C.new.go
