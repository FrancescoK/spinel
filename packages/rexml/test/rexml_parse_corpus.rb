require "rexml/document"

# What REXML builds and writes for each input, and the first line of its
# error for a malformed one.

SRCS = [
  "<a/>", "<a></a>", "<a> </a>", "<a>x</a>\n", "\n\n<a/>\n\n",
  "<?xml version='1.0'?><a/>", "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<a/>",
  "<?xml version='1.1' encoding='UTF-8' standalone='no'?><a/>",
  "<?xml version='1.0' standalone='maybe'?><a/>", "<?xml?><a/>", "<?xml version='1.0'><a/>",
  "<a/><?xml version='1.0'?>", " <?xml version='1.0'?><a/>",
  "<?xml version='1.0'?><?xml version='1.0'?><a/>",
  "<p:a/>", "<a p:b='1'/>", "<a xmlns:p='u'><p:b/></a>", "<a xmlns='u'><b/></a>",
  "<a xmlns:xml='x'/>", "<a xmlns:xmlns='x'/>", "<a xml:lang='en'/>",
  "<a b='1' b='2'/>", "<a b='1'c='2'/>", "<a b = \"1\" />", "<a b='1' />", "<a b/>", "<a b=/>",
  "<a b='1/>", "<a 1b='x'/>", "<a\n  b='x'\n/>",
  "<a>&amp;&lt;&gt;&quot;&apos;</a>", "<a>&nbsp;</a>", "<a>& b</a>", "<a>&#0;</a>", "<a>&#x110000;</a>",
  "<a b='&nbsp;'/>", "<a b='a & b'/>", "<a b='&amp;'/>", "<a b='x&#10;y'/>", "<a b='x\ny'/>", "<a b='x\ty'/>",
  "<a>]]></a>", "<a><![CDATA[]]></a>", "<a><![CDATA[x</a>", "<a><!DOCTYPE x></a>", "<a><!foo></a>",
  "<a><!-- x -- y --></a>", "<a><!-- x ---></a>", "<a><!-- x </a>", "<a><!----></a>",
  "<a><?pi?></a>", "<a><?pi  spaced  ?></a>", "<a><?pi x</a>", "<?pi top?><a/>", "<a><?xml-stylesheet href='x'?></a>",
  "<a><b></b></a>", "<a><b/><c></c></a>", "</a>", "<a></a></a>", "<a><b></c></a>", "<a><b>",
  "<a/><b/>", "<a/>  <!-- c -->  ", "x<a/>", "<a/>x", "", "<", "<a", "<a ", "<a>text", "<>", "< a/>",
  "<a></ a>", "<a></a >", "<a:b:c/>", "<_a.b-c/>", "<a-/>", "<é/>", "<a>é&#233;</a>",
  "<a>\r\nx\ry\r\n</a>", "<a>\t</a>", "<a>tab\there</a>", "<a>x<!--c-->y</a>", "<a>x<b/>y</a>",
]
SRCS.each do |src|
  begin
    d = REXML::Document.new(src)
    r = d.root
    print src.inspect, " => ", d.to_s.inspect
    if r
      print " root=", r.expanded_name, " text=", r.text.inspect, " size=", r.size, " attrs=", r.attributes.to_a.map { |a| [a.expanded_name, a.value, a.to_s] }.inspect
    end
    puts
  rescue REXML::ParseException => e
    puts "#{src.inspect} !! #{e.class}: #{e.message.lines.first.chomp}"
  rescue NotImplementedError => e
    puts "#{src.inspect} !! NotImplementedError"
  end
end
