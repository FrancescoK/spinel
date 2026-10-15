# spinel: gc-stress
# CRuby hands a String part of an interpolation back as it stands, without a
# call of its to_s, so a program that reopens String#to_s does not change
# `"#{x}\<newline>"`. The interpolation is built as it always was in such a
# program (it is rewritten to `x.to_s` only where String has none of its own).
class String
  def to_s = "reopened"
end
s = +"m"
p "#{s}\
"
p "#{s}-#{s}"
