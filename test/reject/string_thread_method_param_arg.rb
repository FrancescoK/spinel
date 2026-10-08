# A single read of a method parameter still leaves its caller observing the String.
# spinel: reject-share
# spinel: reject-thread-string
def m(s)
  Thread.new(s) { |t| t << "!" }.join
  s = nil
end
x = +"a"
m(x)
p x   # CRuby: "a!"; copy: "a"
