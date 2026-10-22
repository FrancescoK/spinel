# A String's own iterator with a block, on a call's poly answer, beside a
# user class that owns the name (StringIO#each_byte). The call reached the
# ordinary poly dispatch, whose switch has no String arm for a call with a
# block, and raised NoMethodError for a String: a user to_s that answers an
# untyped value (openssl's Digest#to_s, its hexdigest's unpack1) made every
# `x.to_s.each_byte { }` on a run-time-typed x do so. aws-sdk-core escapes
# query parameters this way.
require "stringio"

class Tag
  def to_s = ["ab"].pack("a*").unpack1("a*")
end

def bytes(x)
  out = []
  x.to_s.each_byte { |b| out << b }
  out
end

def chars(x)
  out = []
  x.to_s.each_char { |ch| out << ch }
  out
end

def lines(x)
  out = []
  x.to_s.each_line { |l| out << l }
  out
end

def graphemes(x)
  out = []
  x.to_s.each_grapheme_cluster { |g| out << g }
  out
end

p bytes("ok")
p bytes(Tag.new)
p bytes(3)
p chars("ok")
p chars(Tag.new)
p lines("a\nb")
p lines(Tag.new)
p graphemes("ok")
p graphemes(Tag.new)

# aws-sdk-core's escape: CGI.escape with a space as %20 and ~ left as is
def escape(string)
  out = +""
  string.to_s.each_byte do |byte|
    if (byte >= 65 && byte <= 90) || (byte >= 97 && byte <= 122) ||
       (byte >= 48 && byte <= 57) || byte == 45 || byte == 46 || byte == 95 || byte == 126
      out << byte.chr
    else
      out << format("%%%02X", byte)
    end
  end
  out
end

p escape("a b~c/d")
p escape(Tag.new)
p escape(900)

# StringIO keeps its own each_byte
io = StringIO.new("io")
io.each_byte { |b| p b }
