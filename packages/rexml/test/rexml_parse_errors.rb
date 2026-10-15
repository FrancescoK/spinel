require "rexml/document"

# REXML's message: the error, then where its reader stood (line, byte
# position, the unconsumed input it had read).
[
  "<a><b></a>", "<a></b>", "<a/>junk", "<a b=1/>", "   ", "<a>", "</a>",
  "<a>\n  <b x='1'\n</a>", "<r>\n<a/>\n</r>\nzz yy", "<a b='1/>", "x<a/>",
  "<a b='1' b='2'/>", "<a 1b='x'/>", "<a><!-- x -- y --></a>", "<a><![CDATA[x</a>",
  "<?xml version='1.0' standalone='maybe'?><a/>", "<a/><?xml version='1.0'?>",
  "<a xmlns:xml='x'/>", "<z:a z:b='1' xmlns:z='u' b='2'/>", "<a z:b='1' b='2' xmlns:z='u'/>",
].each do |src|
  begin
    REXML::Document.new(src)
    puts "parsed #{src.inspect}"
  rescue REXML::ParseException => e
    puts "#{src.inspect}: #{e.class} line=#{e.line.inspect} position=#{e.position.inspect}"
    puts e.message
  end
end

# An undefined prefix carries no position; an error raised while building
# the tree is quoted (first line: the inner exception).
["<p:a/>", "<a p:b='1'/>", "<a b='<'/>", "<a>& b</a>", "<a>&#0;</a>", "<a/><b/>"].each do |src|
  begin
    REXML::Document.new(src)
  rescue REXML::ParseException => e
    puts "#{src.inspect}: #{e.class} #{e.message.lines.first.chomp}"
  end
end
p REXML::ParseException.ancestors.take(3), REXML::UndefinedNamespaceException.superclass
