require "rexml/document"

[
  %(<?xml version="1.0" encoding="UTF-8"?>\n<a x="1"><b/><c>t &lt; 2</c></a>\n),
  %(<?xml version="1.0" standalone="yes"?><a/>),
  %(<a q='he said "hi"' r="it's" s="1 &lt; 2 &amp; 3 &gt; 0" t="a&#39;b"/>),
  %(<a>raw > gt and &quot;q&quot; and &#65;&#x42; and &apos; and &unknown;</a>),
  %(<a><![CDATA[x < y & z]]></a>),
  %(<a>\n  <b c="1"   d = '2'/>\n</a>),
  %(<!-- top --><a/>\n<!-- after -->\n),
  %(<a><?pi some data?><?bare?></a>),
  %(<a b='1' a='2' xmlns:z='u' z:a='3'/>),
  %(<a>\r\n line\r\n</a>),
  %(<a>é ż &#x17C;</a>),
  %( <a/>),
].each do |src|
  d = REXML::Document.new(src)
  r = d.root
  p d.to_s
  p r.text
  p r.attributes.to_a.map { |a| [a.expanded_name, a.value, a.to_s] }
end

e = REXML::Document.new("<a><b>1</b>tail<b>2</b><c/></a>").root
e.elements["b"].text = %(x"y'z&<>)
p e.to_s
p e.elements["b"].text
e.text = "new"
p e.to_s
e.elements["b"].text = "a&amp;b"
p e.elements["b"].text
p e.to_s
n = e.add_element("d")
n.add_attribute("k", %(v'"<&>))
p n.to_s, n.attributes["k"], n.attribute("k").to_s
n.attributes["k"] = nil
p n.to_s
e.elements["b"].text = nil
p e.to_s
