def m
  y = +"a"
  begin
    return y
  ensure
    @k = y
  end
end
r = m
r << "!"
p @k
