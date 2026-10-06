# frozen_string_literal: true
# Every String method on a literal-derived String (frozen literal, computed,
# +"", empty) and on the shared String buffer (a +"" appended to through
# an alias, the strbuf handle), one probe per call, the receivers in turn.
#
# Each probe holds its receiver in its own local (rN), calls one method and
# prints `[N, answer]` (and the receiver after the call where the method can
# mutate it), or `[N, :raised, ErrorClass]`. Only the probes Spinel answers like
# CRuby 4.0 today are here, checked plain, under --int-overflow=promote and
# under SPINEL_GC_STRESS=1; the ones it gets wrong join with their fix. To add a
# probe, append one in the same shape and regenerate the .expected with
# `make test/<this file>.expected`. The probes came from a method x
# representation grid (GRIDS) run outside the repository; edit this file
# directly.
r0 = "hello"
begin; p [0, (r0 % []), r0]; rescue => e; p [0, :raised, e.class]; end
r1 = "hel" + "lo" * (ARGV.size + 1)
begin; p [1, ("%s!" % r1), r1]; rescue => e; p [1, :raised, e.class]; end
r2 = +"hello"
r2a = r2
r2a << ""
begin; p [2, (r2 * 2), r2]; rescue => e; p [2, :raised, e.class]; end
r3 = +"  Hello World\n"
r3a = r3
r3a << ""
begin; p [3, (r3 * 0), r3]; rescue => e; p [3, :raised, e.class]; end
r4 = "" * (ARGV.size + 1)
begin; p [4, (r4 * -1), r4]; rescue => e; p [4, :raised, e.class]; end
r5 = +"hello"
begin; p [5, (r5 + "x"), r5]; rescue => e; p [5, :raised, e.class]; end
r6 = "hello"
begin; p [6, (r6 + 1), r6]; rescue => e; p [6, :raised, e.class]; end
r7 = "hel" + "lo" * (ARGV.size + 1)
begin; p [7, (+r7), r7]; rescue => e; p [7, :raised, e.class]; end
r8 = +"hello"
r8a = r8
r8a << ""
begin; p [8, (-r8), r8]; rescue => e; p [8, :raised, e.class]; end
r9 = +"  Hello World\n"
r9a = r9
r9a << ""
begin; p [9, ((+r9).frozen?), r9]; rescue => e; p [9, :raised, e.class]; end
r10 = "" * (ARGV.size + 1)
begin; p [10, (r10 << "x"), r10]; rescue => e; p [10, :raised, e.class]; end
r11 = +"hello"
begin; p [11, (r11 << 65), r11]; rescue => e; p [11, :raised, e.class]; end
r12 = "hello"
begin; p [12, (r12 << 0x1F600), r12]; rescue => e; p [12, :raised, e.class]; end
r13 = "hel" + "lo" * (ARGV.size + 1)
begin; p [13, (r13 <=> "hello"), r13]; rescue => e; p [13, :raised, e.class]; end
r14 = +"hello"
r14a = r14
r14a << ""
begin; p [14, (r14 <=> "z"), r14]; rescue => e; p [14, :raised, e.class]; end
r15 = +"  Hello World\n"
r15a = r15
r15a << ""
begin; p [15, (r15 <=> 1), r15]; rescue => e; p [15, :raised, e.class]; end
r16 = "" * (ARGV.size + 1)
begin; p [16, (r16 == "hello"), r16]; rescue => e; p [16, :raised, e.class]; end
r17 = +"hello"
begin; p [17, (r17 == :hello), r17]; rescue => e; p [17, :raised, e.class]; end
r18 = "hello"
begin; p [18, (r18 === "hello"), r18]; rescue => e; p [18, :raised, e.class]; end
r19 = "hel" + "lo" * (ARGV.size + 1)
begin; p [19, (r19 =~ /l+/), r19]; rescue => e; p [19, :raised, e.class]; end
r20 = +"hello"
r20a = r20
r20a << ""
begin; p [20, (r20 =~ /zz/), r20]; rescue => e; p [20, :raised, e.class]; end
r21 = +"  Hello World\n"
r21a = r21
r21a << ""
begin; p [21, ($~ && $~[0]), r21]; rescue => e; p [21, :raised, e.class]; end
r22 = "" * (ARGV.size + 1)
begin; p [22, (r22[0]), r22]; rescue => e; p [22, :raised, e.class]; end
r23 = +"hello"
begin; p [23, (r23[-1]), r23]; rescue => e; p [23, :raised, e.class]; end
r24 = "hello"
begin; p [24, (r24[1, 2]), r24]; rescue => e; p [24, :raised, e.class]; end
r25 = "hel" + "lo" * (ARGV.size + 1)
begin; p [25, (r25[1..]), r25]; rescue => e; p [25, :raised, e.class]; end
r26 = +"hello"
r26a = r26
r26a << ""
begin; p [26, (r26[9]), r26]; rescue => e; p [26, :raised, e.class]; end
r27 = +"  Hello World\n"
r27a = r27
r27a << ""
begin; p [27, (r27[9, 1]), r27]; rescue => e; p [27, :raised, e.class]; end
r28 = "" * (ARGV.size + 1)
begin; p [28, (r28[r28.size, 1]), r28]; rescue => e; p [28, :raised, e.class]; end
r29 = +"hello"
begin; p [29, (r29["ll"]), r29]; rescue => e; p [29, :raised, e.class]; end
r30 = "hello"
begin; p [30, (r30["zz"]), r30]; rescue => e; p [30, :raised, e.class]; end
r31 = "hel" + "lo" * (ARGV.size + 1)
begin; p [31, (r31[/l+/]), r31]; rescue => e; p [31, :raised, e.class]; end
r32 = +"hello"
r32a = r32
r32a << ""
begin; p [32, (r32[/(l)(o)/, 2]), r32]; rescue => e; p [32, :raised, e.class]; end
r33 = +"  Hello World\n"
r33a = r33
r33a << ""
begin; p [33, (r33[1.5]), r33]; rescue => e; p [33, :raised, e.class]; end
r34 = "" * (ARGV.size + 1)
begin; p [34, (r34[0] = "J"), r34]; rescue => e; p [34, :raised, e.class]; end
r35 = +"hello"
begin; p [35, (r35[1, 2] = ""), r35]; rescue => e; p [35, :raised, e.class]; end
r36 = "hello"
begin; p [36, (r36["l"] = "L"), r36]; rescue => e; p [36, :raised, e.class]; end
r37 = "hel" + "lo" * (ARGV.size + 1)
begin; p [37, (r37[9] = "x"), r37]; rescue => e; p [37, :raised, e.class]; end
r38 = +"hello"
r38a = r38
r38a << ""
begin; p [38, (r38[/l/] = "_"), r38]; rescue => e; p [38, :raised, e.class]; end
r39 = +"  Hello World\n"
r39a = r39
r39a << ""
begin; p [39, (r39.append_as_bytes("x")), r39]; rescue => e; p [39, :raised, e.class]; end
r40 = "" * (ARGV.size + 1)
begin; p [40, (r40.ascii_only?), r40]; rescue => e; p [40, :raised, e.class]; end
r41 = +"hello"
begin; p [41, (r41.b), r41]; rescue => e; p [41, :raised, e.class]; end
r42 = "hello"
begin; p [42, (r42.b.encoding), r42]; rescue => e; p [42, :raised, e.class]; end
r43 = "hel" + "lo" * (ARGV.size + 1)
begin; p [43, (r43.byteindex("l")), r43]; rescue => e; p [43, :raised, e.class]; end
r44 = +"hello"
r44a = r44
r44a << ""
begin; p [44, (r44.byterindex("l")), r44]; rescue => e; p [44, :raised, e.class]; end
r45 = +"  Hello World\n"
r45a = r45
r45a << ""
begin; p [45, (r45.bytes), r45]; rescue => e; p [45, :raised, e.class]; end
r46 = "" * (ARGV.size + 1)
begin; p [46, (r46.bytesize), r46]; rescue => e; p [46, :raised, e.class]; end
r47 = +"hello"
begin; p [47, (r47.byteslice(1, 2)), r47]; rescue => e; p [47, :raised, e.class]; end
r48 = "hello"
begin; p [48, (r48.byteslice(9)), r48]; rescue => e; p [48, :raised, e.class]; end
r49 = "hel" + "lo" * (ARGV.size + 1)
begin; p [49, (r49.bytesplice(0, 1, "J")), r49]; rescue => e; p [49, :raised, e.class]; end
r50 = +"hello"
r50a = r50
r50a << ""
begin; p [50, (r50.capitalize), r50]; rescue => e; p [50, :raised, e.class]; end
r51 = +"  Hello World\n"
r51a = r51
r51a << ""
begin; p [51, (r51.capitalize!), r51]; rescue => e; p [51, :raised, e.class]; end
r52 = "" * (ARGV.size + 1)
begin; p [52, (r52.casecmp("HELLO")), r52]; rescue => e; p [52, :raised, e.class]; end
r53 = +"hello"
begin; p [53, (r53.casecmp?("HELLO")), r53]; rescue => e; p [53, :raised, e.class]; end
r54 = "hello"
begin; p [54, (r54.casecmp(1)), r54]; rescue => e; p [54, :raised, e.class]; end
r55 = "hel" + "lo" * (ARGV.size + 1)
begin; p [55, (r55.center(11, "*")), r55]; rescue => e; p [55, :raised, e.class]; end
r56 = +"hello"
r56a = r56
r56a << ""
begin; p [56, (r56.center(2)), r56]; rescue => e; p [56, :raised, e.class]; end
r57 = +"  Hello World\n"
r57a = r57
r57a << ""
begin; p [57, (r57.center(9, "")), r57]; rescue => e; p [57, :raised, e.class]; end
r58 = "" * (ARGV.size + 1)
begin; p [58, (r58.chars), r58]; rescue => e; p [58, :raised, e.class]; end
r59 = +"hello"
begin; p [59, (r59.chomp), r59]; rescue => e; p [59, :raised, e.class]; end
r60 = "hello"
begin; p [60, (r60.chomp("lo")), r60]; rescue => e; p [60, :raised, e.class]; end
r61 = "hel" + "lo" * (ARGV.size + 1)
begin; p [61, (r61.chomp!), r61]; rescue => e; p [61, :raised, e.class]; end
r62 = +"hello"
r62a = r62
r62a << ""
begin; p [62, (r62.chop), r62]; rescue => e; p [62, :raised, e.class]; end
r63 = +"  Hello World\n"
r63a = r63
r63a << ""
begin; p [63, (r63.chop!), r63]; rescue => e; p [63, :raised, e.class]; end
r64 = "" * (ARGV.size + 1)
begin; p [64, (r64.chr), r64]; rescue => e; p [64, :raised, e.class]; end
r65 = +"hello"
begin; p [65, (r65.clear), r65]; rescue => e; p [65, :raised, e.class]; end
r66 = "hello"
begin; p [66, (r66.codepoints), r66]; rescue => e; p [66, :raised, e.class]; end
r67 = "hel" + "lo" * (ARGV.size + 1)
begin; p [67, (r67.concat("a", "b")), r67]; rescue => e; p [67, :raised, e.class]; end
r68 = +"hello"
r68a = r68
r68a << ""
begin; p [68, (r68.concat), r68]; rescue => e; p [68, :raised, e.class]; end
r69 = +"  Hello World\n"
r69a = r69
r69a << ""
begin; p [69, (r69.count("l")), r69]; rescue => e; p [69, :raised, e.class]; end
r70 = "" * (ARGV.size + 1)
begin; p [70, (r70.count("a-z")), r70]; rescue => e; p [70, :raised, e.class]; end
r71 = +"hello"
begin; p [71, (r71.count("^l")), r71]; rescue => e; p [71, :raised, e.class]; end
r72 = "hello"
begin; p [72, (r72.crypt("ab")), r72]; rescue => e; p [72, :raised, e.class]; end
r73 = "hel" + "lo" * (ARGV.size + 1)
begin; p [73, (r73.dedup), r73]; rescue => e; p [73, :raised, e.class]; end
r74 = +"hello"
r74a = r74
r74a << ""
begin; p [74, (r74.delete("l")), r74]; rescue => e; p [74, :raised, e.class]; end
r75 = +"  Hello World\n"
r75a = r75
r75a << ""
begin; p [75, (r75.delete!("z")), r75]; rescue => e; p [75, :raised, e.class]; end
r76 = "" * (ARGV.size + 1)
begin; p [76, (r76.delete("a-k")), r76]; rescue => e; p [76, :raised, e.class]; end
r77 = +"hello"
begin; p [77, (r77.delete_prefix("he")), r77]; rescue => e; p [77, :raised, e.class]; end
r78 = "hello"
begin; p [78, (r78.delete_prefix!("he")), r78]; rescue => e; p [78, :raised, e.class]; end
r79 = "hel" + "lo" * (ARGV.size + 1)
begin; p [79, (r79.delete_suffix("lo")), r79]; rescue => e; p [79, :raised, e.class]; end
r80 = +"hello"
r80a = r80
r80a << ""
begin; p [80, (r80.delete_suffix!("zz")), r80]; rescue => e; p [80, :raised, e.class]; end
r81 = +"  Hello World\n"
r81a = r81
r81a << ""
begin; p [81, (r81.downcase), r81]; rescue => e; p [81, :raised, e.class]; end
r82 = "" * (ARGV.size + 1)
begin; p [82, (r82.downcase!), r82]; rescue => e; p [82, :raised, e.class]; end
r83 = +"hello"
begin; p [83, (r83.dump), r83]; rescue => e; p [83, :raised, e.class]; end
r84 = "hello"
begin; p [84, (r84.dup), r84]; rescue => e; p [84, :raised, e.class]; end
r85 = "hel" + "lo" * (ARGV.size + 1)
begin; p [85, (r85.dup.frozen?), r85]; rescue => e; p [85, :raised, e.class]; end
r86 = +"hello"
r86a = r86
r86a << ""
begin; p [86, (r86.each_byte.to_a), r86]; rescue => e; p [86, :raised, e.class]; end
r87 = +"  Hello World\n"
r87a = r87
r87a << ""
begin; p [87, (r87.each_byte { |b| b }), r87]; rescue => e; p [87, :raised, e.class]; end
r88 = "" * (ARGV.size + 1)
begin; p [88, (r88.each_char.to_a), r88]; rescue => e; p [88, :raised, e.class]; end
r89 = +"hello"
begin; p [89, (r89.each_char { |c| c }), r89]; rescue => e; p [89, :raised, e.class]; end
r90 = "hello"
begin; p [90, (r90.each_codepoint.to_a), r90]; rescue => e; p [90, :raised, e.class]; end
r91 = "hel" + "lo" * (ARGV.size + 1)
begin; p [91, (r91.each_grapheme_cluster.to_a), r91]; rescue => e; p [91, :raised, e.class]; end
r92 = +"hello"
r92a = r92
r92a << ""
begin; p [92, (r92.each_line.to_a), r92]; rescue => e; p [92, :raised, e.class]; end
r93 = +"  Hello World\n"
r93a = r93
r93a << ""
begin; p [93, (r93.each_line("l").to_a), r93]; rescue => e; p [93, :raised, e.class]; end
r94 = "" * (ARGV.size + 1)
begin; p [94, (r94.each_line { |l| l }), r94]; rescue => e; p [94, :raised, e.class]; end
r95 = +"hello"
begin; p [95, (r95.each_line(chomp: true).to_a), r95]; rescue => e; p [95, :raised, e.class]; end
r96 = "hello"
begin; p [96, (r96.empty?), r96]; rescue => e; p [96, :raised, e.class]; end
r97 = "" * (ARGV.size + 1)
begin; p [97, (r97.encode("UTF-16LE").bytesize), r97]; rescue => e; p [97, :raised, e.class]; end
r98 = +"hello"
r98a = r98
r98a << ""
begin; p [98, (r98.encoding), r98]; rescue => e; p [98, :raised, e.class]; end
r99 = +"  Hello World\n"
r99a = r99
r99a << ""
begin; p [99, (r99.end_with?("lo")), r99]; rescue => e; p [99, :raised, e.class]; end
r100 = "" * (ARGV.size + 1)
begin; p [100, (r100.end_with?("x", "")), r100]; rescue => e; p [100, :raised, e.class]; end
r101 = +"hello"
begin; p [101, (r101.eql?("hello")), r101]; rescue => e; p [101, :raised, e.class]; end
r102 = "hello"
begin; p [102, (r102.eql?(:hello)), r102]; rescue => e; p [102, :raised, e.class]; end
r103 = "hel" + "lo" * (ARGV.size + 1)
begin; p [103, (r103.force_encoding("ASCII-8BIT").encoding), r103]; rescue => e; p [103, :raised, e.class]; end
r104 = +"hello"
r104a = r104
r104a << ""
begin; p [104, (r104.freeze), r104]; rescue => e; p [104, :raised, e.class]; end
r105 = +"  Hello World\n"
r105a = r105
r105a << ""
begin; p [105, (r105.frozen?), r105]; rescue => e; p [105, :raised, e.class]; end
r106 = "" * (ARGV.size + 1)
begin; p [106, (r106.getbyte(0)), r106]; rescue => e; p [106, :raised, e.class]; end
r107 = +"hello"
begin; p [107, (r107.getbyte(99)), r107]; rescue => e; p [107, :raised, e.class]; end
r108 = "hello"
begin; p [108, (r108.grapheme_clusters), r108]; rescue => e; p [108, :raised, e.class]; end
r109 = "hel" + "lo" * (ARGV.size + 1)
begin; p [109, (r109.gsub("l", "L")), r109]; rescue => e; p [109, :raised, e.class]; end
r110 = +"hello"
r110a = r110
r110a << ""
begin; p [110, (r110.gsub(/l/) { |m| m.upcase }), r110]; rescue => e; p [110, :raised, e.class]; end
r111 = +"  Hello World\n"
r111a = r111
r111a << ""
begin; p [111, (r111.gsub(/(l)/, '<\1>')), r111]; rescue => e; p [111, :raised, e.class]; end
r112 = "" * (ARGV.size + 1)
begin; p [112, (r112.gsub("l", "l" => "1")), r112]; rescue => e; p [112, :raised, e.class]; end
r113 = +"hello"
begin; p [113, (r113.gsub!("z", "")), r113]; rescue => e; p [113, :raised, e.class]; end
r114 = "hello"
begin; p [114, (r114.gsub!(/[aeiou]/, "*")), r114]; rescue => e; p [114, :raised, e.class]; end
r115 = "hel" + "lo" * (ARGV.size + 1)
begin; p [115, (r115.hash == r115.dup.hash), r115]; rescue => e; p [115, :raised, e.class]; end
r116 = +"hello"
r116a = r116
r116a << ""
begin; p [116, (r116.hex), r116]; rescue => e; p [116, :raised, e.class]; end
r117 = +"  Hello World\n"
r117a = r117
r117a << ""
begin; p [117, (r117.oct), r117]; rescue => e; p [117, :raised, e.class]; end
r118 = "" * (ARGV.size + 1)
begin; p [118, (r118.include?("ll")), r118]; rescue => e; p [118, :raised, e.class]; end
r119 = +"hello"
begin; p [119, (r119.include?("")), r119]; rescue => e; p [119, :raised, e.class]; end
r120 = "hello"
begin; p [120, (r120.index("l")), r120]; rescue => e; p [120, :raised, e.class]; end
r121 = "hel" + "lo" * (ARGV.size + 1)
begin; p [121, (r121.index("l", 3)), r121]; rescue => e; p [121, :raised, e.class]; end
r122 = +"hello"
r122a = r122
r122a << ""
begin; p [122, (r122.index(/o/)), r122]; rescue => e; p [122, :raised, e.class]; end
r123 = +"  Hello World\n"
r123a = r123
r123a << ""
begin; p [123, (r123.index("z")), r123]; rescue => e; p [123, :raised, e.class]; end
r124 = "" * (ARGV.size + 1)
begin; p [124, (r124.index("", 99)), r124]; rescue => e; p [124, :raised, e.class]; end
r125 = +"hello"
begin; p [125, (r125.insert(1, "X")), r125]; rescue => e; p [125, :raised, e.class]; end
r126 = "hello"
begin; p [126, (r126.insert(-1, "X")), r126]; rescue => e; p [126, :raised, e.class]; end
r127 = "hel" + "lo" * (ARGV.size + 1)
begin; p [127, (r127.insert(99, "X")), r127]; rescue => e; p [127, :raised, e.class]; end
r128 = +"hello"
r128a = r128
r128a << ""
begin; p [128, (r128.inspect), r128]; rescue => e; p [128, :raised, e.class]; end
r129 = +"  Hello World\n"
r129a = r129
r129a << ""
begin; p [129, (r129.intern), r129]; rescue => e; p [129, :raised, e.class]; end
r130 = "" * (ARGV.size + 1)
begin; p [130, (r130.to_sym), r130]; rescue => e; p [130, :raised, e.class]; end
r131 = +"hello"
begin; p [131, (r131.length), r131]; rescue => e; p [131, :raised, e.class]; end
r132 = "hello"
begin; p [132, (r132.size), r132]; rescue => e; p [132, :raised, e.class]; end
r133 = "hel" + "lo" * (ARGV.size + 1)
begin; p [133, (r133.lines), r133]; rescue => e; p [133, :raised, e.class]; end
r134 = +"hello"
r134a = r134
r134a << ""
begin; p [134, (r134.ljust(8, ".")), r134]; rescue => e; p [134, :raised, e.class]; end
r135 = +"  Hello World\n"
r135a = r135
r135a << ""
begin; p [135, (r135.rjust(8, ".")), r135]; rescue => e; p [135, :raised, e.class]; end
r136 = "" * (ARGV.size + 1)
begin; p [136, (r136.ljust(2)), r136]; rescue => e; p [136, :raised, e.class]; end
r137 = +"hello"
begin; p [137, (r137.lstrip), r137]; rescue => e; p [137, :raised, e.class]; end
r138 = "hello"
begin; p [138, (r138.lstrip!), r138]; rescue => e; p [138, :raised, e.class]; end
r139 = "hel" + "lo" * (ARGV.size + 1)
begin; p [139, (r139.rstrip), r139]; rescue => e; p [139, :raised, e.class]; end
r140 = +"hello"
r140a = r140
r140a << ""
begin; p [140, (r140.rstrip!), r140]; rescue => e; p [140, :raised, e.class]; end
r141 = +"  Hello World\n"
r141a = r141
r141a << ""
begin; p [141, (r141.strip), r141]; rescue => e; p [141, :raised, e.class]; end
r142 = "" * (ARGV.size + 1)
begin; p [142, (r142.strip!), r142]; rescue => e; p [142, :raised, e.class]; end
r143 = +"hello"
begin; p [143, (r143.match(/l(l)/)&.captures), r143]; rescue => e; p [143, :raised, e.class]; end
r144 = "hello"
begin; p [144, (r144.match(/zz/)), r144]; rescue => e; p [144, :raised, e.class]; end
r145 = "hel" + "lo" * (ARGV.size + 1)
begin; p [145, (r145.match?(/l/)), r145]; rescue => e; p [145, :raised, e.class]; end
r146 = +"hello"
r146a = r146
r146a << ""
begin; p [146, (r146.match?("zz")), r146]; rescue => e; p [146, :raised, e.class]; end
r147 = +"  Hello World\n"
r147a = r147
r147a << ""
begin; p [147, (r147.next), r147]; rescue => e; p [147, :raised, e.class]; end
r148 = "" * (ARGV.size + 1)
begin; p [148, (r148.succ), r148]; rescue => e; p [148, :raised, e.class]; end
r149 = +"hello"
begin; p [149, (r149.next!), r149]; rescue => e; p [149, :raised, e.class]; end
r150 = "hello"
begin; p [150, (r150.ord), r150]; rescue => e; p [150, :raised, e.class]; end
r151 = "hel" + "lo" * (ARGV.size + 1)
begin; p [151, (r151.partition("l")), r151]; rescue => e; p [151, :raised, e.class]; end
r152 = +"hello"
r152a = r152
r152a << ""
begin; p [152, (r152.partition(/z/)), r152]; rescue => e; p [152, :raised, e.class]; end
r153 = +"  Hello World\n"
r153a = r153
r153a << ""
begin; p [153, (r153.rpartition("l")), r153]; rescue => e; p [153, :raised, e.class]; end
r154 = "" * (ARGV.size + 1)
begin; p [154, (r154.prepend("> ")), r154]; rescue => e; p [154, :raised, e.class]; end
r155 = +"hello"
begin; p [155, (r155.replace("bye")), r155]; rescue => e; p [155, :raised, e.class]; end
r156 = "hello"
begin; p [156, (r156.reverse), r156]; rescue => e; p [156, :raised, e.class]; end
r157 = "hel" + "lo" * (ARGV.size + 1)
begin; p [157, (r157.reverse!), r157]; rescue => e; p [157, :raised, e.class]; end
r158 = +"hello"
r158a = r158
r158a << ""
begin; p [158, (r158.rindex("l")), r158]; rescue => e; p [158, :raised, e.class]; end
r159 = +"  Hello World\n"
r159a = r159
r159a << ""
begin; p [159, (r159.rindex("l", 2)), r159]; rescue => e; p [159, :raised, e.class]; end
r160 = "" * (ARGV.size + 1)
begin; p [160, (r160.scan(/l/)), r160]; rescue => e; p [160, :raised, e.class]; end
r161 = +"hello"
begin; p [161, (r161.scan(/(.)(l)/)), r161]; rescue => e; p [161, :raised, e.class]; end
r162 = "hello"
begin; p [162, (r162.scan("l") { |m| m }), r162]; rescue => e; p [162, :raised, e.class]; end
r163 = "hel" + "lo" * (ARGV.size + 1)
begin; p [163, (r163.scrub), r163]; rescue => e; p [163, :raised, e.class]; end
r164 = +"hello"
r164a = r164
r164a << ""
begin; p [164, (r164.scrub!), r164]; rescue => e; p [164, :raised, e.class]; end
r165 = +"  Hello World\n"
r165a = r165
r165a << ""
begin; p [165, (r165.setbyte(0, 74)), r165]; rescue => e; p [165, :raised, e.class]; end
r166 = "" * (ARGV.size + 1)
begin; p [166, (r166.slice(1, 2)), r166]; rescue => e; p [166, :raised, e.class]; end
r167 = +"hello"
begin; p [167, (r167.slice!(1, 2)), r167]; rescue => e; p [167, :raised, e.class]; end
r168 = "hello"
begin; p [168, (r168.slice!(0)), r168]; rescue => e; p [168, :raised, e.class]; end
r169 = "hel" + "lo" * (ARGV.size + 1)
begin; p [169, (r169.slice!(99)), r169]; rescue => e; p [169, :raised, e.class]; end
r170 = +"hello"
r170a = r170
r170a << ""
begin; p [170, (r170.split), r170]; rescue => e; p [170, :raised, e.class]; end
r171 = +"  Hello World\n"
r171a = r171
r171a << ""
begin; p [171, (r171.split("l")), r171]; rescue => e; p [171, :raised, e.class]; end
r172 = "" * (ARGV.size + 1)
begin; p [172, (r172.split("")), r172]; rescue => e; p [172, :raised, e.class]; end
r173 = +"hello"
begin; p [173, (r173.split("l", 2)), r173]; rescue => e; p [173, :raised, e.class]; end
r174 = "hello"
begin; p [174, (r174.split("l", -1)), r174]; rescue => e; p [174, :raised, e.class]; end
r175 = "hel" + "lo" * (ARGV.size + 1)
begin; p [175, (r175.split(/(l)/)), r175]; rescue => e; p [175, :raised, e.class]; end
r176 = +"hello"
r176a = r176
r176a << ""
begin; p [176, (r176.split { |s| s }), r176]; rescue => e; p [176, :raised, e.class]; end
r177 = +"  Hello World\n"
r177a = r177
r177a << ""
begin; p [177, (r177.squeeze), r177]; rescue => e; p [177, :raised, e.class]; end
r178 = "" * (ARGV.size + 1)
begin; p [178, (r178.squeeze("l")), r178]; rescue => e; p [178, :raised, e.class]; end
r179 = +"hello"
begin; p [179, (r179.squeeze!), r179]; rescue => e; p [179, :raised, e.class]; end
r180 = "hello"
begin; p [180, (r180.start_with?("he")), r180]; rescue => e; p [180, :raised, e.class]; end
r181 = "hel" + "lo" * (ARGV.size + 1)
begin; p [181, (r181.start_with?(/h./)), r181]; rescue => e; p [181, :raised, e.class]; end
r182 = +"hello"
r182a = r182
r182a << ""
begin; p [182, (r182.sub("l", "L")), r182]; rescue => e; p [182, :raised, e.class]; end
r183 = +"  Hello World\n"
r183a = r183
r183a << ""
begin; p [183, (r183.sub(/l/) { |m| m * 3 }), r183]; rescue => e; p [183, :raised, e.class]; end
r184 = "" * (ARGV.size + 1)
begin; p [184, (r184.sub!("z", "")), r184]; rescue => e; p [184, :raised, e.class]; end
r185 = +"hello"
begin; p [185, (r185.sub!("l", "")), r185]; rescue => e; p [185, :raised, e.class]; end
r186 = "hello"
begin; p [186, (r186.succ!), r186]; rescue => e; p [186, :raised, e.class]; end
r187 = "hel" + "lo" * (ARGV.size + 1)
begin; p [187, (r187.sum), r187]; rescue => e; p [187, :raised, e.class]; end
r188 = +"hello"
r188a = r188
r188a << ""
begin; p [188, (r188.swapcase), r188]; rescue => e; p [188, :raised, e.class]; end
r189 = +"  Hello World\n"
r189a = r189
r189a << ""
begin; p [189, (r189.swapcase!), r189]; rescue => e; p [189, :raised, e.class]; end
r190 = "" * (ARGV.size + 1)
begin; p [190, (r190.to_c), r190]; rescue => e; p [190, :raised, e.class]; end
r191 = +"hello"
begin; p [191, (r191.to_f), r191]; rescue => e; p [191, :raised, e.class]; end
r192 = "hello"
begin; p [192, (r192.to_i), r192]; rescue => e; p [192, :raised, e.class]; end
r193 = "hel" + "lo" * (ARGV.size + 1)
begin; p [193, (r193.to_i(16)), r193]; rescue => e; p [193, :raised, e.class]; end
r194 = +"hello"
r194a = r194
r194a << ""
begin; p [194, (r194.to_r), r194]; rescue => e; p [194, :raised, e.class]; end
r195 = +"  Hello World\n"
r195a = r195
r195a << ""
begin; p [195, (r195.to_s), r195]; rescue => e; p [195, :raised, e.class]; end
r196 = "" * (ARGV.size + 1)
begin; p [196, (r196.to_str), r196]; rescue => e; p [196, :raised, e.class]; end
r197 = +"hello"
begin; p [197, (r197.tr("el", "ip")), r197]; rescue => e; p [197, :raised, e.class]; end
r198 = "hello"
begin; p [198, (r198.tr("a-y", "b-z")), r198]; rescue => e; p [198, :raised, e.class]; end
r199 = "hel" + "lo" * (ARGV.size + 1)
begin; p [199, (r199.tr("^l", "*")), r199]; rescue => e; p [199, :raised, e.class]; end
r200 = +"hello"
r200a = r200
r200a << ""
begin; p [200, (r200.tr!("z", "y")), r200]; rescue => e; p [200, :raised, e.class]; end
r201 = +"  Hello World\n"
r201a = r201
r201a << ""
begin; p [201, (r201.tr_s("l", "r")), r201]; rescue => e; p [201, :raised, e.class]; end
r202 = "" * (ARGV.size + 1)
begin; p [202, (r202.tr_s!("l", "r")), r202]; rescue => e; p [202, :raised, e.class]; end
r203 = +"hello"
begin; p [203, (r203.undump rescue :bad), r203]; rescue => e; p [203, :raised, e.class]; end
r204 = "hello"
begin; p [204, (r204.dump.undump), r204]; rescue => e; p [204, :raised, e.class]; end
r205 = +"  Hello World\n"
r205a = r205
r205a << ""
begin; p [205, (r205.unpack("C*")), r205]; rescue => e; p [205, :raised, e.class]; end
r206 = "" * (ARGV.size + 1)
begin; p [206, (r206.unpack1("a3")), r206]; rescue => e; p [206, :raised, e.class]; end
r207 = +"hello"
begin; p [207, (r207.upcase), r207]; rescue => e; p [207, :raised, e.class]; end
r208 = "hello"
begin; p [208, (r208.upcase!), r208]; rescue => e; p [208, :raised, e.class]; end
r209 = "hel" + "lo" * (ARGV.size + 1)
begin; p [209, (r209.upto(r209.succ).to_a), r209]; rescue => e; p [209, :raised, e.class]; end
r210 = +"hello"
r210a = r210
r210a << ""
begin; p [210, (r210.valid_encoding?), r210]; rescue => e; p [210, :raised, e.class]; end
r211 = +"  Hello World\n"
r211a = r211
r211a << ""
begin; p [211, (r211.encode!("UTF-8").encoding), r211]; rescue => e; p [211, :raised, e.class]; end
r212 = "" * (ARGV.size + 1)
begin; p [212, (r212.class), r212]; rescue => e; p [212, :raised, e.class]; end
r213 = +"hello"
begin; p [213, (r213.nil?), r213]; rescue => e; p [213, :raised, e.class]; end
r214 = "hello"
begin; p [214, (r214.is_a?(String)), r214]; rescue => e; p [214, :raised, e.class]; end
r215 = "hel" + "lo" * (ARGV.size + 1)
begin; p [215, (r215.is_a?(Comparable)), r215]; rescue => e; p [215, :raised, e.class]; end
r216 = +"hello"
r216a = r216
r216a << ""
begin; p [216, (r216.respond_to?(:upcase)), r216]; rescue => e; p [216, :raised, e.class]; end
r217 = +"  Hello World\n"
r217a = r217
r217a << ""
begin; p [217, (r217.itself), r217]; rescue => e; p [217, :raised, e.class]; end
r218 = "" * (ARGV.size + 1)
begin; p [218, (r218.tap { |q| q }), r218]; rescue => e; p [218, :raised, e.class]; end
r219 = +"hello"
begin; p [219, (r219.then { |q| q.size }), r219]; rescue => e; p [219, :raised, e.class]; end
r220 = "hello"
begin; p [220, (r220.send(:upcase)), r220]; rescue => e; p [220, :raised, e.class]; end
r221 = "hel" + "lo" * (ARGV.size + 1)
begin; p [221, (r221.public_send(:size)), r221]; rescue => e; p [221, :raised, e.class]; end
r222 = +"hello"
r222a = r222
r222a << ""
begin; p [222, (r222.method(:size).call), r222]; rescue => e; p [222, :raised, e.class]; end
r223 = +"  Hello World\n"
r223a = r223
r223a << ""
begin; p [223, (r223.instance_variables), r223]; rescue => e; p [223, :raised, e.class]; end
r224 = "" * (ARGV.size + 1)
begin; p [224, (r224.equal?(r224)), r224]; rescue => e; p [224, :raised, e.class]; end
r225 = +"hello"
begin; p [225, (r225.object_id == r225.object_id), r225]; rescue => e; p [225, :raised, e.class]; end
r226 = "hello"
begin; p [226, (r226.between?("a", "z")), r226]; rescue => e; p [226, :raised, e.class]; end
r227 = "hel" + "lo" * (ARGV.size + 1)
begin; p [227, (r227.clamp("a", "c")), r227]; rescue => e; p [227, :raised, e.class]; end
r228 = +"hello"
r228a = r228
r228a << ""
begin; p [228, (r228 > "a"), r228]; rescue => e; p [228, :raised, e.class]; end
r229 = +"  Hello World\n"
r229a = r229
r229a << ""
begin; p [229, (r229 <= ""), r229]; rescue => e; p [229, :raised, e.class]; end
r230 = "" * (ARGV.size + 1)
begin; p [230, (!r230), r230]; rescue => e; p [230, :raised, e.class]; end
r231 = +"hello"
begin; p [231, (r231 && 1), r231]; rescue => e; p [231, :raised, e.class]; end
r232 = "hello"
begin; p [232, ("<#{r232}>"), r232]; rescue => e; p [232, :raised, e.class]; end
r233 = "hel" + "lo" * (ARGV.size + 1)
begin; p [233, (format("%-8s|", r233)), r233]; rescue => e; p [233, :raised, e.class]; end
r234 = +"hello"
r234a = r234
r234a << ""
begin; p [234, (Integer(r234) rescue :bad), r234]; rescue => e; p [234, :raised, e.class]; end
r235 = +"  Hello World\n"
r235a = r235
r235a << ""
begin; p [235, (Float(r235) rescue :bad), r235]; rescue => e; p [235, :raised, e.class]; end
r236 = "" * (ARGV.size + 1)
begin; p [236, (Array(r236)), r236]; rescue => e; p [236, :raised, e.class]; end
r237 = +"hello"
begin; p [237, (String(r237)), r237]; rescue => e; p [237, :raised, e.class]; end
r238 = "hello"
begin; p [238, ([r238, "a"].sort), r238]; rescue => e; p [238, :raised, e.class]; end
r239 = "hel" + "lo" * (ARGV.size + 1)
begin; p [239, ([r239].join(",")), r239]; rescue => e; p [239, :raised, e.class]; end
r240 = +"hello"
r240a = r240
r240a << ""
begin; p [240, (r240.chars.sort.join), r240]; rescue => e; p [240, :raised, e.class]; end
r241 = +"  Hello World\n"
r241a = r241
r241a << ""
begin; p [241, (r241.each_char.with_index.map { |c, i| i }), r241]; rescue => e; p [241, :raised, e.class]; end
r242 = "" * (ARGV.size + 1)
begin; p [242, (r242.size.class), r242]; rescue => e; p [242, :raised, e.class]; end
r243 = +"hello"
begin; p [243, (case r243 when /ll/ then :m else :n end), r243]; rescue => e; p [243, :raised, e.class]; end
r244 = "hello"
begin; p [244, (case r244 when String then :s end), r244]; rescue => e; p [244, :raised, e.class]; end
r245 = "hel" + "lo" * (ARGV.size + 1)
begin; p [245, (r245.upcase.downcase == r245.downcase), r245]; rescue => e; p [245, :raised, e.class]; end
r246 = +"hello"
r246a = r246
r246a << ""
begin; p [246, (r246.freeze.upcase!), r246]; rescue => e; p [246, :raised, e.class]; end
r247 = +"  Hello World\n"
r247a = r247
r247a << ""
begin; p [247, (r247.frozen? ? :f : r247.concat("!")), r247]; rescue => e; p [247, :raised, e.class]; end
r248 = "" * (ARGV.size + 1)
begin; p [248, ((r248 << "a" << "b")), r248]; rescue => e; p [248, :raised, e.class]; end
r249 = +"hello"
begin; p [249, (r249.dup << "z"), r249]; rescue => e; p [249, :raised, e.class]; end
