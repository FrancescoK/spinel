# `text.gsub(/re/, rep)` where the receiver and the replacement may each be
# more than one class: the replacement converts as it does on a String
# receiver.
class Comment
  def initialize(t) = @t = t
  def to_str = @t
end

def change_encoding(text, encoding)
  if text.kind_of? Comment
    text
  else
    String.new text, encoding: encoding
  end
end

def strip_blank(text)
  return text unless text =~ /\S/
  empty = ""
  empty = change_encoding empty, text.encoding if text.encoding
  text.gsub(/^\s+$/, empty)
end

p strip_blank("a\n  \nb")
p strip_blank(:" ")
p change_encoding(Comment.new("c"), Encoding::UTF_8).class

def swap(text, rep) = text.gsub(/x/, rep)
def once(text, rep) = text.sub(/x/, rep)

texts = ["axbx", nil]
reps = ["-", Comment.new("+")]
reps.each do |r|
  p swap(texts[0], r)
  p once(texts[0], r)
end
begin
  swap(texts[0], [1, "y"][0])
rescue TypeError => e
  p e.message
end
