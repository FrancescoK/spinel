# Narrowed boxes read their bytes without first allocating a String handle.
# The share target checks the C as well as these values, including in a loop.
def read_narrowed(value)
  identity = value.object_id
  if value.is_a?(String)
    p value.object_id == identity
    2.times do
      p value.bytesize, value.length, value == "abc", value.to_s
      p "<#{value}>", value.upcase, value[0], value.include?("b")
    end
  else
    p value
  end
end

read_narrowed("abc")
read_narrowed(+"abc")
read_narrowed(7)
