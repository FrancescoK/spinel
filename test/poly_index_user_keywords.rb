# A user method named index, rindex or find_index that takes keywords,
# called on a receiver of more than one type (here `x || raise`). The
# builtin index arms read the keywords from a temp that was never declared,
# and the C did not compile. A builtin receiver at the same call takes the
# keywords as one Hash argument, as CRuby does.
class Changes
  def index(path, against:) = [:index, path, against]
  def rindex(path, against:) = [:rindex, path, against]
  def find_index(against:) = [:find_index, against]
end

def pick(kind)
  case kind
  when :changes then Changes.new
  when :string then "abcb"
  when :array then [1, { against: "head" }]
  end
end

changes = pick(:changes)
p((changes || raise(ArgumentError)).index("/a", against: "head"))
p((changes || raise(ArgumentError)).rindex("/a", against: "head"))
p((changes || raise(ArgumentError)).find_index(against: "head"))

array = pick(:array)
p array.index(against: "head")
p array.rindex(against: "head")
p array.find_index(against: "head")
p array.index(against: "base")

string = pick(:string)
p string.index("b")
p string.rindex("b", 2)
begin
  string.index("b", against: "head")
rescue TypeError => e
  p e.class
end
begin
  string.rindex(against: "head")
rescue TypeError => e
  p e.class
end
