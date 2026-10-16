require "rexml/document"

# Child paths: an unprefixed name matches in the default namespace, a prefixed
# one by the namespace URI its prefix is bound to.
r = REXML::Document.new("<r xmlns='u'><b/></r>").root
p r.elements["b"]&.name, r.elements.size
r = REXML::Document.new("<r xmlns:p='u' xmlns:q='u'><p:b/><b/><q:c/></r>").root
p r.elements["b"]&.expanded_name, r.elements["p:b"]&.expanded_name, r.elements["q:b"]&.expanded_name, r.elements["c"]&.expanded_name, r.elements["q:c"]&.expanded_name,r.elements["p:c"]&.expanded_name
p r.elements.to_a("b").map(&:expanded_name), r.elements.to_a("*").map(&:expanded_name)
r2 = REXML::Document.new("<r><a><b>1</b><b>2</b></a><a><b>3</b></a></r>").root
p r2.elements.to_a("a/b").map(&:text), r2.elements.to_a("*/b").map(&:text), r2.elements["a/b"].text
p r2.elements.to_a("a/*").size
d = REXML::Document.new("<r><a/></r>")
p d.elements["r"].name, d.elements["r/a"].name, d.elements["*"].name, d.elements.to_a.size
p d.root.elements["r"]
