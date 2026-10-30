# A call on a boxed receiver whose every reached arm raises never returns,
# and an equality on it is no equality to refuse (call_never_returns). A
# class nothing names keeps its own `id` unreached: counted as an arm, its
# Integer answer made the call look like one that returns, and the
# comparison of two such calls was refused ("unsupported equality"), as a
# roundhouse app with no model was on ActiveRecord::Base's `==` (#10636).
class Record
  def id = raise(NotImplementedError, "id: subclasses must override")
  def same?(other) = other.id == id
end
class Unused
  def id = 42
end
r = Record.new
[Record.new, "s"].each do |o|
  begin
    p r.same?(o)
  rescue NotImplementedError, NoMethodError => e
    puts e.class
  end
end
