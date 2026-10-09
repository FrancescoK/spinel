x = +"v"
[5, nil, :s, 1.5].each do |k|
  begin
    r = ENV.store(k, x)
    r << "!"
  rescue TypeError => e
    p e.message
  end
end
p x
begin
  r = ENV.store("RVENV_R1", 5)
  p r
rescue TypeError => e
  p e.message
end
y = +"y"
begin
  r = (ENV[:sym] = y)
  r << "?"
rescue TypeError => e
  p e.message
end
p y
