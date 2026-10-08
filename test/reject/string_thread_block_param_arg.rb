# A block parameter is not a plain local even when its only read passes it on.
# spinel: reject-share
# spinel: reject-thread-string
x = +"a"
[x].each do |s|
  Thread.new(s) { |t| t << "!" }.join
  s = nil
end
p x
