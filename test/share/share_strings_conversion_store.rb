# A receiver conversion stored in a container keeps the same mutable
# String. Nil follows each conversion's own rule.
def conversions(flag)
  s = flag ? +'x' : nil
  text = [s.to_s]
  s << '!' if s
  p text
  begin
    strict = {0 => s.to_str}
    s << '?' if s
    p strict[0]
  rescue NoMethodError
    puts 'NoMethodError'
  end
  same = [s.itself]
  s << '.' if s
  p same
  begin
    s.itself << ':'
    p s
  rescue NoMethodError
    puts 'nil itself'
  end
end
conversions(true)
conversions(false)

class OwnText
  def to_s
    'own'
  end
end
p [OwnText.new.to_s]
