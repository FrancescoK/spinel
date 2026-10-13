# A character assignment into a String held in a container takes a String,
# as String#[]= does: an Integer, a Float, a Symbol, nil, true, a Class, an
# Encoding or a Range raises CRuby's TypeError instead of splicing in its
# to_s, and the String is left as it was. A String, or an object with
# #to_str, is spliced in.
class Name
  def to_str = "Z"
end

words = [+"ab", +"cd"]
[1, 2.5, :s, nil, true, String, Encoding::UTF_8, 1..2].each do |v|
  begin
    words[0][0] = v
  rescue TypeError => e
    p e.message
  end
end
p words

h = { k: +"ef" }
begin
  h[:k][0, 1] = 7
rescue TypeError => e
  p e.message
end
p h

words[1][0] = "X"
words[0][1] = Name.new
p words
