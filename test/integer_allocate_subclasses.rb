# Integer.allocate raises CRuby's TypeError; Integer.subclasses is empty.
begin
  Integer.allocate
rescue => e
  p [e.class, e.message]
end
begin
  [Integer, 0][0].allocate
rescue => e
  p [e.class, e.message]
end
p Integer.subclasses
p [Integer, 0][0].subclasses
