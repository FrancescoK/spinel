def m(c)
  y = +"a"
  z = @z ||= +"z"
  c ? y : z
end
r = m(false)
r << "!"
p @z
