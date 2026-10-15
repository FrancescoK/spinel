# spinel: share
# spinel: gc-minor
# A method answering an Array of shared Strings or nil, asked through a safe
# navigation: the nil skips the call, the Array answers it, and an Integer
# answer (size, length) is the call's own.
def maybe(f)
  s = +"s"
  a = [s]
  s << "!"
  f ? a : nil
end
def early(f)
  s = +"s"
  a = [s]
  s << "!"
  return nil unless f
  a
end
x = maybe(true)
y = maybe(false)
p x&.size, y&.size
p(x&.length, y&.length)
p x&.size.to_s, y&.size.to_s
p maybe(true)&.size, maybe(false)&.size
p x&.first, x&.last, y&.last
p x&.join("-"), x&.empty?, y&.empty?
p(x&.include?("s!"), y&.include?("s!"))
p(x&.each { |e| e << "." })
p y&.each { |e| e << "." }
p(x&.push(+"x"))
p x, y
e = early(true)
p e.size if e
p early(false)
