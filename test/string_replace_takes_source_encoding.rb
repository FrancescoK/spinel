# spinel: share
# String#replace gives the receiver the source's encoding, also through a box.
class Sub < String
end
x = Sub.new("\xff".b)
p x.encoding
p x.to_s.encoding
y = Sub.new("q")
y.replace("\xfe".b)
p y.encoding
y.replace("ok")
p y.encoding
z = [1, "a".b][1]
z.replace("é")
p z.encoding
