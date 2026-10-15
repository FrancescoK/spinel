require "rexml/document"

# Attributes keyed by local name, Element#inspect, Elements by index, text
# and CDATA nodes, and writing.

a = REXML::Document.new("<a b='1' a='2' xmlns:z='u' z:a='3'/>").root
p a.attributes["a"], a.attributes["z:a"], a.attribute("a").to_s, a.attributes.size, a.attributes.length
p a.attributes.keys
a.attributes.each { |k, v| p [k, v] }
a.attributes.each { |pair| p pair }
a.attributes.each_attribute { |at| p at.expanded_name }
p a.inspect, a.to_s
p a.attribute("z:a").prefix, a.attribute("z:a").name, a.attribute("a").prefix
p a.attributes.delete("a").class, a.to_s
x = REXML::Element.new
p x.name, x.to_s
y = REXML::Element.new("y")
p y.inspect
y.add_attribute("k", "v")
y.text = "t"
p y.inspect, y.to_s
p y.add_element("z").inspect
p y.inspect
e = REXML::Document.new("<r><a/><b/></r>").root
begin
  e.elements[0]
rescue => err
  p err.class, err.message
end
begin; p e.elements[-1]; rescue => err; p err.class; end
d = REXML::Document.new("<r/>")
begin
  d.add_element("s")
rescue => err
  p err.class, err.message
end
p d.version, d.encoding, d.xml_decl.class, d.xml_decl.to_s
d2 = REXML::Document.new("<?xml version='1.1'?><r/>")
p d2.version, d2.encoding if d2
p REXML::Document.new("<r/>").name, REXML::Document.new("<r/>").expanded_name
t = REXML::Document.new("<r>a<b/>c</r>").root
p t.texts.map(&:value), t.get_text.class, t.get_text.value
t.text = "Z"
p t.to_s
t.add_text("q")
p t.to_s
t.elements.delete(t.elements["b"])
p t.to_s, t.size
c = REXML::Document.new("<r><![CDATA[a<b]]></r>").root
p c.text, c.get_text.class, c.to_s
c.add_text("x")
p c.to_s
w = REXML::Document.new("<r><s/></r>")
out = +""
w.write(out)
p out
s = REXML::Document.new("<r/>").root
s.add_attribute("n", 5)
s.add_attribute("m", "a'b\"c")
p s.to_s, s.attributes["n"]
s.attributes["o"] = "x"
p s.attributes.to_a.map(&:to_string)
p s.has_attributes?, REXML::Element.new("q").has_attributes?
p s.root.equal?(s), s.document.class
q = REXML::Element.new("q")
q.add_element("r").add_element("t")
p q.elements["r/t"].root.name
p q.elements.to_a.size, q.elements.size, q.elements.empty?
