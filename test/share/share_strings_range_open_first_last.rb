# --share-strings: #first and #last with no count on a beginless or endless
# String Range raise CRuby's RangeError, where #begin and #end answer nil,
# wherever the endpoint is handed on: read, yielded, boxed, compared.
# spinel: gc-stress

e = String.new("c")
q = (..e)
s = String.new("m")
w = (s..)
def y(r) = yield(r.last)
y(q) { |x| x << "!" }
p q, q.begin, w.end
[-> { q.first }, -> { w.last }, -> { p q.first, 1 }, -> { p w.last, 1 },
 -> { y(w) { |x| p x }; nil }, -> { q.first.equal?(e) }, -> { w.last.object_id }].each do |f|
  begin
    f.call
    p :no_error
  rescue RangeError => ex
    p ex.message
  end
end
p w.first, q.last
