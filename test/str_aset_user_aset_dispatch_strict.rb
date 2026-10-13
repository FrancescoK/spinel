# `s[i] = v` on a String reaches a dispatch when a program class owns `[]=`
# (here a String subclass). The String's arm takes the replacement as
# String#[]= does: a String or a #to_str goes in, and an Integer, a Symbol,
# nil, a Class or a Range raises CRuby's TypeError instead of being spliced
# in as its to_s, through an Integer index and through a String key alike.
class Digits < String
  def []=(i, v)
    super(i, v.to_s)
  end
end

class Name
  def to_str = "N"
end

words = [+"ab", +"cd", +"ef"]
[1, :s, nil, String, 1..2].each do |v|
  begin
    words[0][0] = v
  rescue TypeError => e
    p e.message
  end
  begin
    words[2]["e"] = v
  rescue TypeError => e
    p e.message
  end
end
words[1] << "!"
p words

words[0][0] = "Z"
words[2]["e"] = Name.new
p words

# a String element nothing appends to
plain = [+"gh"]
begin
  plain[0][0] = 2
rescue TypeError => e
  p e.message
end
plain[0][1] = "H"
p plain

p Digits.new("xy").tap { |d| d[0] = 5 }
