# A program's nil? or is_a? that answers something other than true or false
# answers that value through a boxed receiver too.
class U
  def nil?; "U:nil?"; end
end

class K
  def is_a?(c); :k_is_a; end
end

[U.new, 5, nil].each { |x| p x.nil? }
[K.new, "s"].each { |x| p x.is_a?(String) }
