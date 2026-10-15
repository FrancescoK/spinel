require "rexml/document"

doc = REXML::Document.new("<r><a id='1'><x>1</x></a><b/><a id='2'><x>2</x><y/></a>text</r>")
r = doc.root
p r.name, r.elements.size, r.elements.to_a.map(&:name)
p r.elements[1].name, r.elements[3].attributes["id"], r.elements[9]
p r.elements["a"].attributes["id"], r.elements["*"].name, r.elements["a/x"].text, r.elements["a/y"].name
p r.elements["nope"], r.elements["a/nope"]
r.elements.each { |el| print el.name, " " }
puts
r.elements.each("a") { |el| print el.attributes["id"], " " }
puts
p r.get_elements("a").size, r.elements.to_a("a/x").map(&:text)
r.each_element { |el| print el.name }
puts
p r.text, r.has_text?, r.has_elements?, r.elements["b"].has_elements?
c = r.add_element("c", { "k" => "v" })
p c.to_s, c.parent.name, c.document.class, c.root.name, r.parent.class, doc.root.equal?(r)
c.add_text("one")
c.add_text(" two")
p c.text, c.to_s
p r.delete_element(r.elements["b"]).name, r.to_s
el = REXML::Element.new("z")
el.add_attribute("q", "1")
el.text = "hi"
p el.to_s, el.attributes["q"], el.name, el.prefix
ns = REXML::Document.new("<p:a xmlns:p='u'><p:b p:c='1'/></p:a>").root
p ns.name, ns.prefix, ns.expanded_name, ns.elements["p:b"].attributes["p:c"]
p REXML::Document.new("").root, REXML::Document.new.to_s
d = REXML::Document.new
d.add_element("root").add_attribute("v", "1")
p d.to_s
