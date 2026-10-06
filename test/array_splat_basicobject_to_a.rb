obj = BasicObject.new
def obj.to_a
  [2, 3, 4]
end

p [1, *obj]

plain = BasicObject.new
p [*plain].length

nil_obj = BasicObject.new
def nil_obj.to_a
  nil
end
nil_result = [*nil_obj]
p nil_result.length
p nil_result[0].equal?(nil_obj)

bad_obj = BasicObject.new
def bad_obj.to_a
  "not an array"
end
begin
  [*bad_obj]
rescue TypeError
  puts "TypeError"
end
