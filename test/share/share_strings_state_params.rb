# A state-changing parameter takes the same handle as every caller alias.
def binary_state(s)
  s.force_encoding("ASCII-8BIT")
  0
end
def frozen_state(s)
  s.freeze
  0
end
def encoded_state(s)
  s.encode!("ASCII-8BIT")
  0
end
def splice_state(s) = s.bytesplice(0, 1, "Q")
s = +"abc"
p splice_state(s), s
s = +"abc"
binary_state(s)
p s.encoding == Encoding::BINARY
s = +"abc"
t = s
t << "x"
binary_state(s)
p s.encoding == Encoding::BINARY, t.encoding == Encoding::BINARY
frozen_state(s)
p s.frozen?, t.frozen?
s = +"abc"
t = s
t << "y"
encoded_state(s)
p s.encoding == Encoding::BINARY, t.encoding == Encoding::BINARY
