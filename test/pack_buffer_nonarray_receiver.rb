# spinel: share
# Array#pack with buffer: on a boxed receiver: a value without Array's
# pack raises NoMethodError instead of packing as an empty Array.
class NoPack; end
class MyArr < Array; end
class OwnPack
  def pack(format, buffer: nil)
    "own:#{format}:#{buffer.inspect}"
  end
end
def pack_value(value)
  begin
    p value.pack("C*", buffer: nil)
  rescue NoMethodError => e
    p [e.name, e.message]
  end
end
sub = MyArr.new
sub << 67
pack_value([65])
pack_value(sub)
pack_value(NoPack.new)
pack_value(Object.new)
pack_value(OwnPack.new)
pack_value(nil)
pack_value("bytes")
pack_value(1..2)
p [66].pack("C*", buffer: +"prefix")
