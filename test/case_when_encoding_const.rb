# An Encoding constant in `when` (Encoding::UTF_8) is an equality test, as
# Encoding#=== is; it was taken for a class name and the arm folded to
# false. unicode_normalize dispatches on the String's encoding this way.

def kind(s)
  case s.encoding
  when Encoding::UTF_8 then :utf8
  when Encoding::US_ASCII then :ascii
  when Encoding::BINARY then :binary
  else :other
  end
end

p kind("x")
p kind("x".b)

def text?(enc)
  case enc
  when Encoding::UTF_8, Encoding::US_ASCII then true
  else false
  end
end

p text?(Encoding::UTF_8), text?(Encoding::ASCII_8BIT), text?(nil)

# As a statement, against a boxed local.
e = "é".encoding
case e
when Encoding::ASCII_8BIT then puts "binary"
when Encoding::UTF_8 then puts "utf-8"
end

# `when Encoding` tests the class of a boxed Encoding.
r = case e
    when Encoding then :an_encoding
    else :no
    end
p r
