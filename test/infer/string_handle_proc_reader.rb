# A proc that only reads its String keeps the plain `const char *` parameter,
# and so does the String its caller hands it, beside a proc that appends to a
# String of its own: the handle is made where a target appends (#6179).
app = proc { |t| t << "!" * 100; nil }
read = proc { |r| r.size }
buf = +"a"
app.call(buf)
line = +"hello"
n = 0
i = 0
while i < 1000
  n += read.call(line)
  i += 1
end
p n, buf.size
