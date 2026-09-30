# A keyword argument whose call always raises NoMethodError, beside another
# keyword value with an effect: the arguments run ahead of the call, and the
# raising one's slot still has to build (#6024).
def tag(label:, size:)
  p [label, size]
end

tag(label: { k: 1 }, size: 2)
widget = { name: "a" }
begin
  tag(label: widget.id, size: widget.size)
rescue NoMethodError => e
  p e.message
end
begin
  tag(label: { name: "a" }.id, size: "x".size)
rescue NoMethodError => e
  p e.message
end

def pos(a, b) = p([a, b])
pos(1, 2)
begin
  pos(widget.id, widget.size)
rescue NoMethodError => e
  p e.message
end
