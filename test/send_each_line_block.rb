def ev(o, m, *a, &b) = o.send(m, *a, &b)
def evk(o, m, *a, **k, &b) = o.send(m, *a, **k, &b)
def pub(o, m, *a, &b) = o.public_send(m, *a, &b)
def plain(o, m, &b) = o.send(m, &b)
def plainpub(o, m, &b) = o.public_send(m, &b)

text = "a\nb\n"
boxed = [1, "a\nb\n"][1]

r = []
ev(text, :each_line) { |l| r << l }
p r
r = []
evk(text, :each_line, chomp: true) { |l| r << l }
p r
r = []
pub(text, :each_line) { |l| r << l }
p r

[:each_char, :each_line].each do |m|
  r = []
  ev(boxed, m) { |x| r << x }
  p r
  r = []
  pub(boxed, m) { |x| r << x }
  p r
end
r = []
evk(boxed, :each_line, chomp: true) { |l| r << l }
p r

r = []
blk = proc { |x| r << x }
boxed.send(:each_char, &blk)
boxed.send(:each_line, &blk)
p r

r = []
plain(text, :each_line) { |l| r << l }
p r
p plain("xy", :size)
p plain("xy", :each_char).class
r = []
plainpub("ab", :each_byte) { |x| r << x }
p r
p plainpub("xy", :size)
