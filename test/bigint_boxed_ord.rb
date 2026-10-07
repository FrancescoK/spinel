# spinel: int64 -- assumes a 64-bit Integer (2 ** 100)
# Integer#ord answers the receiver, so a boxed Bignum (here the element of
# a mixed Array) answers itself rather than NoMethodError.
b = [2 ** 100, "x"][0]
p [b.ord.class, b.ord]
p [b.ord.equal?(b), b.ord + 1]
class Custom
  def ord; :custom; end
end
[Custom.new, b, -(2 ** 100), 5, -7, 0, "a", "é", ""].each do |value|
  begin
    p value.ord
  rescue => error
    p [error.class, error.message]
  end
end
