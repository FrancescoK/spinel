# A regexp search of a UTF-8 String that is not valid UTF-8 raises
# ArgumentError, as in CRuby; a binary or a valid String is searched.
def t(name)
  r = yield
  puts "#{name}: #{r.inspect}"
rescue ArgumentError => e
  puts "#{name}: ArgumentError: #{e.message}"
end
s = "a\xffb c"
t("=~") { s =~ /b/ }
t("re=~") { /b/ =~ s }
t("match") { s.match(/b/) && 1 }
t("match_pos") { s.match(/c/, 3) && 1 }
t("match?") { s.match?(/b/) }
t("re.match?") { /b/.match?(s) }
t("scan") { s.scan(/b/) }
t("scan_groups") { s.scan(/(b)/) }
t("gsub") { s.gsub(/b/, "x") }
t("gsub_block") { s.gsub(/b/) { "x" } }
t("gsub_hash") { s.gsub(/b/, "b" => "x") }
t("sub") { s.sub(/b/, "x") }
t("sub_hash") { s.sub(/b/, "b" => "x") }
t("split") { s.split(/ /) }
t("index") { s.index(/b/) }
t("index_pos") { s.index(/c/, 2) }
t("rindex") { s.rindex(/b/) }
t("byteindex") { s.byteindex(/b/) }
t("partition") { s.partition(/ /) }
t("rpartition") { s.rpartition(/ /) }
t("start_with") { s.start_with?(/a/) }
t("slice") { s[/b/] }
t("slice!") { s.dup.slice!(/b/) }
t("aset") { x = s.dup; x[/b/] = "y"; x }
t("gsub_str") { s.gsub("b", "x") }
t("index_str") { s.index("b") }
t("bin") { s.b.scan(/b/) }
t("valid") { "héllo".scan(/l/) }
t("case") { case s; when /b/ then 1; else 2; end }
u = "a\xffb" + ""
p u.length
t("after_length") { u =~ /b/ }
v = "ñandú" + ""
p v.length
t("valid_after_length") { v =~ /d/ }
t("forced_binary") { u.dup.force_encoding("BINARY") =~ /b/ }
