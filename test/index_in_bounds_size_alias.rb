# A read below a size held in a local (`len = a.bytesize; while i < len`)
# is inside the String or Array, so a byte or an element read there is no
# nil, and Integer's & | ^ on it need no nil test. A write to the local or
# to the String, or a call that can shrink it, ends what the local knows.

def slot(msg)
  yield.inspect
rescue NotImplementedError => e
  e.message == msg ? msg[/answers (\w+)/, 1] : e.message
end
XOR = "nil ^ Integer answers true or false, which an Integer slot cannot hold"

def xor_bytes(a, b)
  len = a.bytesize
  out = a.dup
  i = 0
  while i < len
    out.setbyte(i, a.getbyte(i) ^ b.getbyte(i) & 0x1f)
    i = i.succ
  end
  out.bytes
end
p xor_bytes("abc", "xyz")

# an Array's size in a local, and `i = i + 1`
arr = [5, 6, 7]
m = arr.size
k = 0
acc = []
while k < m
  v = arr[k] | 8
  acc << v
  k = k + 1
end
p acc

# the String cleared after its size was taken: the read is nil
s = +"abcd"
len = s.bytesize
s.clear
i = 0
while i < len
  puts slot(XOR) { y = s.getbyte(i) ^ 1; y }
  i += 1
end

# the local rewritten to a shorter String: nil again
t = +"abcd"
n = t.size
t = "a"
j = 0
while j < n
  puts slot(XOR) { y = t.getbyte(j) ^ 2; y }
  j = j + 1
end
