# unpack(fmt, offset: n) on a boxed String (a value out of a Queue, out of a
# Mutex's block, out of a mixed Array): with the keyword the call raised
# NoMethodError, and a multiple assignment from it was refused at compile time.
# unpack1 takes the keyword the same way (#7317).

# a STUN-like message: header, transaction id, one SOFTWARE attribute naming
# Jayang-dong, padded to four bytes
msg = [0x0101, 16, 0x2112a442].pack("nnN") + ("\x00" * 12).b +
      [0x8022, 11].pack("nn") + "Jayang-dong".b + "\x00".b

q = Queue.new
q << msg
s = q.pop
type, length = s.unpack("nn", offset: 0)
p [type, length]
at, al = s.unpack("nn", offset: 20)
p [at, al]
p s.unpack("a11", offset: 24)
off = 20
p s.unpack("n2", offset: off + 2)
p s.unpack1("a6", offset: 24)

lock = Mutex.new
held = [msg]
t = lock.synchronize { held.shift }
magic, = t.unpack("N", offset: 4)
p magic.to_s(16)

m = [msg, 5][0]
p m.unpack("Ca3", offset: 24)
p m.unpack("n", offset: msg.bytesize)

begin
  s.unpack("n", offset: 99)
rescue ArgumentError => e
  puts "ArgumentError: #{e.message}"
end
begin
  [5, "x"][0].unpack("C", offset: 0)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
