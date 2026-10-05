# A raise message with a NUL in it keeps the bytes after it (#7556).
begin
  raise ArgumentError, "before\0after"
rescue ArgumentError => e
  p e.message
end
m = "x\0y" + "z"
begin
  raise m
rescue => e
  p e.message, e.message.bytesize
end
begin
  raise IOError.new("a\0b")
rescue IOError => e
  p e.message
end
