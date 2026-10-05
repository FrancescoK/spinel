# A method's own block handed on to fetch, delete or fetch_values (`def
# fb(&b) = h.fetch(k, &b)`, or an anonymous `&`) is the fallback for a
# missing key, as a block literal is; it was ignored and the call answered
# nil. A call of the method without a block takes the blockless form:
# fetch raises KeyError (IndexError for an Array) and delete answers nil.
def t
  yield
rescue KeyError, IndexError => e
  puts "#{e.class}: #{e.message}"
end
def fb(&b) = { "a" => 1 }.fetch("q", &b)
p fb { |k| k + "!" }
t { p fb }
def present(&b) = { "a" => 1 }.fetch("a", &b)
p present { 0 }, present
def anon(&) = { "a" => 1 }.fetch("q", &)
p anon { |k| k + "?" }
def idx(&b) = [1, 2].fetch(9, &b)
p idx { |i| i * 2 }
t { p idx }
def del(&b) = { "a" => 1 }.delete("q", &b)
p del { |k| k + "!" }, del
def adel(&b) = [1, 2].delete(7, &b)
p adel { |v| v * 2 }, adel
def vals(&b) = { "a" => 1 }.fetch_values("a", "z", &b)
p vals { |k| k * 2 }
def local(&b)
  h = { a: 1 }
  h.fetch(:q, &b)
end
p local { |k| k.to_s }
class K
  def fb(&b) = { a: 1 }.fetch(:q, &b)
end
p K.new.fb { |k| k.to_s }
t { K.new.fb }
