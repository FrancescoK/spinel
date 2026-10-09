# spinel: share
# spinel: gc-minor
# A frozen literal keeps one identity through its byte and shared faces.
def literal_text = "frozen"
def equal_literal_text = "frozen"
def literal_empty = ""
def literal_binary = "a\0b"
def literal_choice(s, n) = n == 0 ? "frozen" : s

x = literal_text
y = literal_text
begin
  x << "!"
rescue FrozenError
end
p x.equal?(y), x.equal?(equal_literal_text), x.equal?("frozen"), x.frozen?
p x.object_id == y.object_id
p x.object_id == equal_literal_text.object_id
p x.object_id == "frozen".object_id
boxed = ["frozen", 0]
p x.equal?(boxed[0]), boxed[0].equal?(x)
p x.object_id == boxed[0].object_id

empty = literal_empty
binary = literal_binary
[empty, binary].each do |text|
  begin
    text << "!"
  rescue FrozenError
  end
end
p empty.equal?(literal_empty), empty.equal?("")
p binary.equal?(literal_binary), binary.equal?("a\0b"), binary.bytes
source = +"source"
a = literal_choice(source, ARGV.size)
b = literal_choice(source, ARGV.size)
begin
  a << "!"
rescue FrozenError
end
p a.equal?(b), a.equal?(x), source
GC.start
p literal_text.equal?(x), literal_binary.equal?(binary)

p catch("frozen") { throw x, :literal_tag }
p catch(x) { throw "frozen", :handle_tag }

copy = x.clone
mutable = x.dup
p copy.equal?(x), copy.frozen?, mutable.equal?(x), mutable.frozen?
mutable << "!"
p mutable, x
