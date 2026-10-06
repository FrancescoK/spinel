# frozen_string_literal: true
# Every Hash method on the typed hash variants (StrInt, StrStr, IntStr,
# IntInt, StrPoly, SymPoly, PolyPoly), with a default value, a
# default_proc and neither, one probe per call, the receivers in turn.
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
r0 = Hash.new(0)
r0["a"] = 1
r0["b"] = 2
begin; p [0, (r0["a"]), r0]; rescue => e; p [0, :raised, e.class]; end
r1 = {1 => "x", 2 => "y"}
begin; p [1, (r1[9]), r1]; rescue => e; p [1, :raised, e.class]; end
r2 = {"a" => "x", "b" => "y"}
begin; p [2, (r2[nil]), r2]; rescue => e; p [2, :raised, e.class]; end
r3 = {1 => 10}
r3.clear
begin; p [3, (r3[3] = 30), r3]; rescue => e; p [3, :raised, e.class]; end
r4 = {a: 1, b: 2}
begin; p [4, (r4.store(:a, 3)), r4]; rescue => e; p [4, :raised, e.class]; end
r5 = {"a" => 1, "b" => "x"}
begin; p [5, (r5["a"] = :w), r5]; rescue => e; p [5, :raised, e.class]; end
r6 = Hash.new { |hh, kk| hh[kk] = [kk] }
r6[1] = "a"
r6["b"] = 2
begin; p [6, (r6.fetch(1)), r6]; rescue => e; p [6, :raised, e.class]; end
r7 = {"a" => 1, "b" => 2}
begin; p [7, (r7.fetch("z")), r7]; rescue => e; p [7, :raised, e.class]; end
r8 = Hash.new(-1)
r8[1] = 10
r8[2] = 20
begin; p [8, (r8.fetch(9, :d)), r8]; rescue => e; p [8, :raised, e.class]; end
r9 = Hash.new(0)
r9["a"] = 1
r9["b"] = 2
begin; p [9, (r9.fetch("z") { |k| [k] }), r9]; rescue => e; p [9, :raised, e.class]; end
r10 = {1 => "x", 2 => "y"}
begin; p [10, (r10.fetch(1, :d)), r10]; rescue => e; p [10, :raised, e.class]; end
r11 = {"a" => "x", "b" => "y"}
begin; p [11, (r11.dig("a")), r11]; rescue => e; p [11, :raised, e.class]; end
r12 = {1 => 10}
r12.clear
begin; p [12, (r12.dig(9)), r12]; rescue => e; p [12, :raised, e.class]; end
r13 = {a: 1, b: 2}
begin; p [13, (r13.key(1)), r13]; rescue => e; p [13, :raised, e.class]; end
r14 = {"a" => 1, "b" => "x"}
begin; p [14, (r14.key(:w)), r14]; rescue => e; p [14, :raised, e.class]; end
r15 = Hash.new { |hh, kk| hh[kk] = [kk] }
r15[1] = "a"
r15["b"] = 2
begin; p [15, (r15.key?(1)), r15]; rescue => e; p [15, :raised, e.class]; end
r16 = {"a" => 1, "b" => 2}
begin; p [16, (r16.key?("z")), r16]; rescue => e; p [16, :raised, e.class]; end
r17 = Hash.new(-1)
r17[1] = 10
r17[2] = 20
begin; p [17, (r17.has_key?(1)), r17]; rescue => e; p [17, :raised, e.class]; end
r18 = Hash.new(0)
r18["a"] = 1
r18["b"] = 2
begin; p [18, (r18.include?("a")), r18]; rescue => e; p [18, :raised, e.class]; end
r19 = {1 => "x", 2 => "y"}
begin; p [19, (r19.member?(9)), r19]; rescue => e; p [19, :raised, e.class]; end
r20 = {"a" => "x", "b" => "y"}
begin; p [20, (r20.value?("x")), r20]; rescue => e; p [20, :raised, e.class]; end
r21 = {1 => 10}
r21.clear
begin; p [21, (r21.value?(30)), r21]; rescue => e; p [21, :raised, e.class]; end
r22 = {a: 1, b: 2}
begin; p [22, (r22.has_value?(1)), r22]; rescue => e; p [22, :raised, e.class]; end
r23 = {"a" => 1, "b" => "x"}
begin; p [23, (r23.keys), r23]; rescue => e; p [23, :raised, e.class]; end
r24 = Hash.new { |hh, kk| hh[kk] = [kk] }
r24[1] = "a"
r24["b"] = 2
begin; p [24, (r24.values), r24]; rescue => e; p [24, :raised, e.class]; end
r25 = {"a" => 1, "b" => 2}
begin; p [25, (r25.values_at("a", "z")), r25]; rescue => e; p [25, :raised, e.class]; end
r26 = Hash.new(-1)
r26[1] = 10
r26[2] = 20
begin; p [26, (r26.fetch_values(1)), r26]; rescue => e; p [26, :raised, e.class]; end
r27 = Hash.new(0)
r27["a"] = 1
r27["b"] = 2
begin; p [27, (r27.fetch_values("z")), r27]; rescue => e; p [27, :raised, e.class]; end
r28 = {1 => "x", 2 => "y"}
begin; p [28, (r28.fetch_values(9) { |k| 0 }), r28]; rescue => e; p [28, :raised, e.class]; end
r29 = {"a" => "x", "b" => "y"}
begin; p [29, (r29.length), r29]; rescue => e; p [29, :raised, e.class]; end
r30 = {1 => 10}
r30.clear
begin; p [30, (r30.size), r30]; rescue => e; p [30, :raised, e.class]; end
r31 = {a: 1, b: 2}
begin; p [31, (r31.empty?), r31]; rescue => e; p [31, :raised, e.class]; end
r32 = {"a" => 1, "b" => "x"}
begin; p [32, (r32.count), r32]; rescue => e; p [32, :raised, e.class]; end
r33 = Hash.new { |hh, kk| hh[kk] = [kk] }
r33[1] = "a"
r33["b"] = 2
begin; p [33, (r33.count { |k, v| v == "a" }), r33]; rescue => e; p [33, :raised, e.class]; end
r34 = {"a" => 1, "b" => 2}
begin; p [34, (r34.delete("a")), r34]; rescue => e; p [34, :raised, e.class]; end
r35 = Hash.new(-1)
r35[1] = 10
r35[2] = 20
begin; p [35, (r35.delete(9)), r35]; rescue => e; p [35, :raised, e.class]; end
r36 = {a: 1, b: 2}
begin; p [36, (r36.delete(:z) { |k| [:nf, k] }), r36]; rescue => e; p [36, :raised, e.class]; end
r37 = {1 => "x", 2 => "y"}
begin; p [37, (r37.delete_if { |k, v| k == 1 }), r37]; rescue => e; p [37, :raised, e.class]; end
r38 = {"a" => "x", "b" => "y"}
begin; p [38, (r38.keep_if { |k, v| k == "a" }), r38]; rescue => e; p [38, :raised, e.class]; end
r39 = {1 => 10}
r39.clear
begin; p [39, (r39.select! { |k, v| true }), r39]; rescue => e; p [39, :raised, e.class]; end
r40 = {a: 1, b: 2}
begin; p [40, (r40.reject! { |k, v| false }), r40]; rescue => e; p [40, :raised, e.class]; end
r41 = {"a" => 1, "b" => "x"}
begin; p [41, (r41.filter! { |k, v| k == "a" }), r41]; rescue => e; p [41, :raised, e.class]; end
r42 = Hash.new { |hh, kk| hh[kk] = [kk] }
r42[1] = "a"
r42["b"] = 2
begin; p [42, (r42.reject! { |k, v| k == 1 }), r42]; rescue => e; p [42, :raised, e.class]; end
r43 = {"a" => 1, "b" => 2}
begin; p [43, (r43.select { |k, v| k == "a" }), r43]; rescue => e; p [43, :raised, e.class]; end
r44 = Hash.new(-1)
r44[1] = 10
r44[2] = 20
begin; p [44, (r44.filter { |k, v| v == 10 }), r44]; rescue => e; p [44, :raised, e.class]; end
r45 = Hash.new(0)
r45["a"] = 1
r45["b"] = 2
begin; p [45, (r45.reject { |k, v| k == "a" }), r45]; rescue => e; p [45, :raised, e.class]; end
r46 = {1 => "x", 2 => "y"}
begin; p [46, (r46.each { |k, v| k }), r46]; rescue => e; p [46, :raised, e.class]; end
r47 = {"a" => "x", "b" => "y"}
begin; p [47, (r47.each_pair { |k, v| v }), r47]; rescue => e; p [47, :raised, e.class]; end
r48 = {1 => 10}
r48.clear
begin; p [48, (r48.each_key { |k| k }), r48]; rescue => e; p [48, :raised, e.class]; end
r49 = {a: 1, b: 2}
begin; p [49, (r49.each_value { |v| v }), r49]; rescue => e; p [49, :raised, e.class]; end
r50 = {"a" => 1, "b" => "x"}
begin; p [50, (r50.each { |kv| kv }), r50]; rescue => e; p [50, :raised, e.class]; end
r51 = Hash.new { |hh, kk| hh[kk] = [kk] }
r51[1] = "a"
r51["b"] = 2
begin; p [51, (r51.each.to_a), r51]; rescue => e; p [51, :raised, e.class]; end
r52 = {"a" => 1, "b" => 2}
begin; p [52, (r52.each_key.to_a), r52]; rescue => e; p [52, :raised, e.class]; end
r53 = Hash.new(-1)
r53[1] = 10
r53[2] = 20
begin; p [53, (r53.each_with_index.to_a), r53]; rescue => e; p [53, :raised, e.class]; end
r54 = Hash.new(0)
r54["a"] = 1
r54["b"] = 2
begin; p [54, (r54.each_with_index { |(k, v), i| i }), r54]; rescue => e; p [54, :raised, e.class]; end
r55 = {1 => "x", 2 => "y"}
begin; p [55, (r55.each_with_object([]) { |(k, v), acc| acc << k }), r55]; rescue => e; p [55, :raised, e.class]; end
r56 = {"a" => "x", "b" => "y"}
begin; p [56, (r56.map { |k, v| [k, v] }), r56]; rescue => e; p [56, :raised, e.class]; end
r57 = {1 => 10}
r57.clear
begin; p [57, (r57.map { |kv| kv }), r57]; rescue => e; p [57, :raised, e.class]; end
r58 = {a: 1, b: 2}
begin; p [58, (r58.flat_map { |k, v| [k] }), r58]; rescue => e; p [58, :raised, e.class]; end
r59 = {"a" => 1, "b" => "x"}
begin; p [59, (r59.filter_map { |k, v| k if v == 1 }), r59]; rescue => e; p [59, :raised, e.class]; end
r60 = Hash.new { |hh, kk| hh[kk] = [kk] }
r60[1] = "a"
r60["b"] = 2
begin; p [60, (r60.to_a), r60]; rescue => e; p [60, :raised, e.class]; end
r61 = {"a" => 1, "b" => 2}
begin; p [61, (r61.entries), r61]; rescue => e; p [61, :raised, e.class]; end
r62 = Hash.new(-1)
r62[1] = 10
r62[2] = 20
begin; p [62, (r62.to_h), r62]; rescue => e; p [62, :raised, e.class]; end
r63 = Hash.new(0)
r63["a"] = 1
r63["b"] = 2
begin; p [63, (r63.to_h { |k, v| [v, k] }), r63]; rescue => e; p [63, :raised, e.class]; end
r64 = {1 => "x", 2 => "y"}
begin; p [64, (r64.to_hash), r64]; rescue => e; p [64, :raised, e.class]; end
r65 = {"a" => "x", "b" => "y"}
begin; p [65, (r65.sort_by { |k, v| k.to_s }), r65]; rescue => e; p [65, :raised, e.class]; end
r66 = {1 => 10}
r66.clear
begin; p [66, (r66.min_by { |k, v| v.to_s }), r66]; rescue => e; p [66, :raised, e.class]; end
r67 = {a: 1, b: 2}
begin; p [67, (r67.max_by { |k, v| k.to_s }), r67]; rescue => e; p [67, :raised, e.class]; end
r68 = {"a" => 1, "b" => "x"}
begin; p [68, (r68.sum { |k, v| 1 }), r68]; rescue => e; p [68, :raised, e.class]; end
r69 = Hash.new { |hh, kk| hh[kk] = [kk] }
r69[1] = "a"
r69["b"] = 2
begin; p [69, (r69.find { |k, v| k == 1 }), r69]; rescue => e; p [69, :raised, e.class]; end
r70 = {"a" => 1, "b" => 2}
begin; p [70, (r70.detect { |k, v| false }), r70]; rescue => e; p [70, :raised, e.class]; end
r71 = Hash.new(-1)
r71[1] = 10
r71[2] = 20
begin; p [71, (r71.any?), r71]; rescue => e; p [71, :raised, e.class]; end
r72 = Hash.new(0)
r72["a"] = 1
r72["b"] = 2
begin; p [72, (r72.any? { |k, v| v == 1 }), r72]; rescue => e; p [72, :raised, e.class]; end
r73 = {1 => "x", 2 => "y"}
begin; p [73, (r73.all? { |k, v| k }), r73]; rescue => e; p [73, :raised, e.class]; end
r74 = {"a" => "x", "b" => "y"}
begin; p [74, (r74.none? { |k, v| k == "z" }), r74]; rescue => e; p [74, :raised, e.class]; end
r75 = {1 => 10}
r75.clear
begin; p [75, (r75.one? { |k, v| k == 1 }), r75]; rescue => e; p [75, :raised, e.class]; end
r76 = {a: 1, b: 2}
begin; p [76, (r76.group_by { |k, v| v.class }), r76]; rescue => e; p [76, :raised, e.class]; end
r77 = {"a" => 1, "b" => "x"}
begin; p [77, (r77.partition { |k, v| k == "a" }), r77]; rescue => e; p [77, :raised, e.class]; end
r78 = Hash.new { |hh, kk| hh[kk] = [kk] }
r78[1] = "a"
r78["b"] = 2
begin; p [78, (r78.inject(0) { |a, (k, v)| a + 1 }), r78]; rescue => e; p [78, :raised, e.class]; end
r79 = {"a" => 1, "b" => 2}
begin; p [79, (r79.reduce([]) { |a, kv| a + kv }), r79]; rescue => e; p [79, :raised, e.class]; end
r80 = Hash.new(-1)
r80[1] = 10
r80[2] = 20
begin; p [80, (r80.sort), r80]; rescue => e; p [80, :raised, e.class]; end
r81 = Hash.new(0)
r81["a"] = 1
r81["b"] = 2
begin; p [81, (r81.min_by(2) { |k, v| k.to_s }), r81]; rescue => e; p [81, :raised, e.class]; end
r82 = {1 => "x", 2 => "y"}
begin; p [82, (r82.first), r82]; rescue => e; p [82, :raised, e.class]; end
r83 = {"a" => "x", "b" => "y"}
begin; p [83, (r83.first(1)), r83]; rescue => e; p [83, :raised, e.class]; end
r84 = {1 => 10}
r84.clear
begin; p [84, (r84.take(1)), r84]; rescue => e; p [84, :raised, e.class]; end
r85 = {a: 1, b: 2}
begin; p [85, (r85.drop(1)), r85]; rescue => e; p [85, :raised, e.class]; end
r86 = {"a" => 1, "b" => "x"}
begin; p [86, (r86.zip([1])), r86]; rescue => e; p [86, :raised, e.class]; end
r87 = Hash.new { |hh, kk| hh[kk] = [kk] }
r87[1] = "a"
r87["b"] = 2
begin; p [87, (r87.tally), r87]; rescue => e; p [87, :raised, e.class]; end
r88 = {"a" => 1, "b" => 2}
begin; p [88, (r88.uniq), r88]; rescue => e; p [88, :raised, e.class]; end
r89 = Hash.new(-1)
r89[1] = 10
r89[2] = 20
begin; p [89, (r89.each_slice(1).to_a), r89]; rescue => e; p [89, :raised, e.class]; end
r90 = Hash.new(0)
r90["a"] = 1
r90["b"] = 2
begin; p [90, (r90.find_all { |k, v| true }), r90]; rescue => e; p [90, :raised, e.class]; end
r91 = {1 => "x", 2 => "y"}
begin; p [91, (r91.merge({3 => "w"})), r91]; rescue => e; p [91, :raised, e.class]; end
r92 = {"a" => "x", "b" => "y"}
begin; p [92, (r92.merge({"a" => "w"}) { |k, a, b| [a, b] }), r92]; rescue => e; p [92, :raised, e.class]; end
r93 = {1 => 10}
r93.clear
begin; p [93, (r93.merge), r93]; rescue => e; p [93, :raised, e.class]; end
r94 = {a: 1, b: 2}
begin; p [94, (r94.merge({}, {:c => 3})), r94]; rescue => e; p [94, :raised, e.class]; end
r95 = {"a" => 1, "b" => "x"}
begin; p [95, (r95.merge({9.5 => 1})), r95]; rescue => e; p [95, :raised, e.class]; end
r96 = Hash.new { |hh, kk| hh[kk] = [kk] }
r96[1] = "a"
r96["b"] = 2
begin; p [96, (r96.merge!({:c => 3.5})), r96]; rescue => e; p [96, :raised, e.class]; end
r97 = {"a" => 1, "b" => 2}
begin; p [97, (r97.update({"a" => 3}) { |k, a, b| b }), r97]; rescue => e; p [97, :raised, e.class]; end
r98 = Hash.new(-1)
r98[1] = 10
r98[2] = 20
begin; p [98, (r98.replace({3 => 30})), r98]; rescue => e; p [98, :raised, e.class]; end
r99 = Hash.new(0)
r99["a"] = 1
r99["b"] = 2
begin; p [99, (r99.clear), r99]; rescue => e; p [99, :raised, e.class]; end
r100 = {1 => "x", 2 => "y"}
begin; p [100, (r100.invert), r100]; rescue => e; p [100, :raised, e.class]; end
r101 = {"a" => "x", "b" => "y"}
begin; p [101, (r101.transform_values { |v| v.to_s }), r101]; rescue => e; p [101, :raised, e.class]; end
r102 = {1 => 10}
r102.clear
begin; p [102, (r102.transform_values(&:class)), r102]; rescue => e; p [102, :raised, e.class]; end
r103 = {a: 1, b: 2}
begin; p [103, (r103.transform_keys { |k| k.to_s }), r103]; rescue => e; p [103, :raised, e.class]; end
r104 = {"a" => 1, "b" => "x"}
begin; p [104, (r104.transform_keys({"a" => "c"})), r104]; rescue => e; p [104, :raised, e.class]; end
r105 = Hash.new { |hh, kk| hh[kk] = [kk] }
r105[1] = "a"
r105["b"] = 2
begin; p [105, (r105.transform_values! { |v| v }), r105]; rescue => e; p [105, :raised, e.class]; end
r106 = {"a" => 1, "b" => 2}
begin; p [106, (r106.transform_keys! { |k| k }), r106]; rescue => e; p [106, :raised, e.class]; end
r107 = Hash.new(-1)
r107[1] = 10
r107[2] = 20
begin; p [107, (r107.transform_values! { |v| v.to_s }), r107]; rescue => e; p [107, :raised, e.class]; end
r108 = Hash.new(0)
r108["a"] = 1
r108["b"] = 2
begin; p [108, (r108.compact), r108]; rescue => e; p [108, :raised, e.class]; end
r109 = {a: 1, b: 2}
begin; p [109, (r109.compact!), r109]; rescue => e; p [109, :raised, e.class]; end
r110 = {"a" => "x", "b" => "y"}
begin; p [110, (r110.slice("a")), r110]; rescue => e; p [110, :raised, e.class]; end
r111 = {1 => 10}
r111.clear
begin; p [111, (r111.slice(9)), r111]; rescue => e; p [111, :raised, e.class]; end
r112 = {a: 1, b: 2}
begin; p [112, (r112.except(:a)), r112]; rescue => e; p [112, :raised, e.class]; end
r113 = {"a" => 1, "b" => "x"}
begin; p [113, (r113.except), r113]; rescue => e; p [113, :raised, e.class]; end
r114 = Hash.new { |hh, kk| hh[kk] = [kk] }
r114[1] = "a"
r114["b"] = 2
begin; p [114, (r114.assoc(1)), r114]; rescue => e; p [114, :raised, e.class]; end
r115 = {"a" => 1, "b" => 2}
begin; p [115, (r115.assoc("z")), r115]; rescue => e; p [115, :raised, e.class]; end
r116 = Hash.new(-1)
r116[1] = 10
r116[2] = 20
begin; p [116, (r116.rassoc(10)), r116]; rescue => e; p [116, :raised, e.class]; end
r117 = Hash.new(0)
r117["a"] = 1
r117["b"] = 2
begin; p [117, (r117.flatten), r117]; rescue => e; p [117, :raised, e.class]; end
r118 = {1 => "x", 2 => "y"}
begin; p [118, (r118.flatten(2)), r118]; rescue => e; p [118, :raised, e.class]; end
r119 = {"a" => "x", "b" => "y"}
begin; p [119, (r119.default), r119]; rescue => e; p [119, :raised, e.class]; end
r120 = {1 => 10}
r120.clear
begin; p [120, (r120.default(9)), r120]; rescue => e; p [120, :raised, e.class]; end
r121 = {a: 1, b: 2}
begin; p [121, (r121.default_proc.nil?), r121]; rescue => e; p [121, :raised, e.class]; end
r122 = {"a" => 1, "b" => "x"}
begin; p [122, (r122.default = :w; r122["z"]), r122]; rescue => e; p [122, :raised, e.class]; end
r123 = Hash.new(-1)
r123[1] = 10
r123[2] = 20
begin; p [123, (r123.compare_by_identity?), r123]; rescue => e; p [123, :raised, e.class]; end
r124 = Hash.new(0)
r124["a"] = 1
r124["b"] = 2
begin; p [124, (r124.shift), r124]; rescue => e; p [124, :raised, e.class]; end
r125 = {1 => "x", 2 => "y"}
begin; p [125, (r125.rehash), r125]; rescue => e; p [125, :raised, e.class]; end
r126 = {"a" => "x", "b" => "y"}
begin; p [126, (r126.to_proc.call("a")), r126]; rescue => e; p [126, :raised, e.class]; end
r127 = {1 => 10}
r127.clear
begin; p [127, (r127.to_proc.call(9)), r127]; rescue => e; p [127, :raised, e.class]; end
r128 = {a: 1, b: 2}
begin; p [128, (r128 == r128.dup), r128]; rescue => e; p [128, :raised, e.class]; end
r129 = {"a" => 1, "b" => "x"}
begin; p [129, (r129 == {}), r129]; rescue => e; p [129, :raised, e.class]; end
r130 = Hash.new { |hh, kk| hh[kk] = [kk] }
r130[1] = "a"
r130["b"] = 2
begin; p [130, (r130 == {1 => "a"}), r130]; rescue => e; p [130, :raised, e.class]; end
r131 = {"a" => 1, "b" => 2}
begin; p [131, (r131.eql?(r131.dup)), r131]; rescue => e; p [131, :raised, e.class]; end
r132 = Hash.new(-1)
r132[1] = 10
r132[2] = 20
begin; p [132, (r132 != 1), r132]; rescue => e; p [132, :raised, e.class]; end
r133 = Hash.new(0)
r133["a"] = 1
r133["b"] = 2
begin; p [133, (r133 < {"a" => 1, "c" => 3}), r133]; rescue => e; p [133, :raised, e.class]; end
r134 = {1 => "x", 2 => "y"}
begin; p [134, (r134 <= r134), r134]; rescue => e; p [134, :raised, e.class]; end
r135 = {"a" => "x", "b" => "y"}
begin; p [135, (r135 > {}), r135]; rescue => e; p [135, :raised, e.class]; end
r136 = {1 => 10}
r136.clear
begin; p [136, (r136 >= {9 => 1}), r136]; rescue => e; p [136, :raised, e.class]; end
r137 = {a: 1, b: 2}
begin; p [137, (r137.hash == r137.dup.hash), r137]; rescue => e; p [137, :raised, e.class]; end
r138 = {"a" => 1, "b" => "x"}
begin; p [138, (r138.inspect), r138]; rescue => e; p [138, :raised, e.class]; end
r139 = Hash.new { |hh, kk| hh[kk] = [kk] }
r139[1] = "a"
r139["b"] = 2
begin; p [139, (r139.to_s), r139]; rescue => e; p [139, :raised, e.class]; end
r140 = {"a" => 1, "b" => 2}
begin; p [140, (r140.freeze), r140]; rescue => e; p [140, :raised, e.class]; end
r141 = Hash.new(-1)
r141[1] = 10
r141[2] = 20
begin; p [141, (r141.frozen?), r141]; rescue => e; p [141, :raised, e.class]; end
r142 = Hash.new(0)
r142["a"] = 1
r142["b"] = 2
begin; p [142, (r142.freeze["c"] = 3), r142]; rescue => e; p [142, :raised, e.class]; end
r143 = {1 => "x", 2 => "y"}
begin; p [143, (r143.dup.frozen?), r143]; rescue => e; p [143, :raised, e.class]; end
r144 = {"a" => "x", "b" => "y"}
begin; p [144, (r144.deconstruct_keys(nil)), r144]; rescue => e; p [144, :raised, e.class]; end
r145 = {1 => 10}
r145.clear
begin; p [145, (r145.dup), r145]; rescue => e; p [145, :raised, e.class]; end
r146 = {a: 1, b: 2}
begin; p [146, (r146.clone), r146]; rescue => e; p [146, :raised, e.class]; end
r147 = {"a" => 1, "b" => "x"}
begin; p [147, (r147.sum([]) { |k, v| [k] }), r147]; rescue => e; p [147, :raised, e.class]; end
r148 = Hash.new { |hh, kk| hh[kk] = [kk] }
r148[1] = "a"
r148["b"] = 2
begin; p [148, (r148.class), r148]; rescue => e; p [148, :raised, e.class]; end
r149 = {"a" => 1, "b" => 2}
begin; p [149, (r149.nil?), r149]; rescue => e; p [149, :raised, e.class]; end
r150 = Hash.new(-1)
r150[1] = 10
r150[2] = 20
begin; p [150, (r150.is_a?(Hash)), r150]; rescue => e; p [150, :raised, e.class]; end
r151 = Hash.new(0)
r151["a"] = 1
r151["b"] = 2
begin; p [151, (r151.is_a?(Enumerable)), r151]; rescue => e; p [151, :raised, e.class]; end
r152 = {1 => "x", 2 => "y"}
begin; p [152, (r152.respond_to?(:each_pair)), r152]; rescue => e; p [152, :raised, e.class]; end
r153 = {"a" => "x", "b" => "y"}
begin; p [153, (r153.itself), r153]; rescue => e; p [153, :raised, e.class]; end
r154 = {1 => 10}
r154.clear
begin; p [154, (r154.tap { |q| q }), r154]; rescue => e; p [154, :raised, e.class]; end
r155 = {a: 1, b: 2}
begin; p [155, (r155.then { |q| q.size }), r155]; rescue => e; p [155, :raised, e.class]; end
r156 = {"a" => 1, "b" => "x"}
begin; p [156, (r156.send(:size)), r156]; rescue => e; p [156, :raised, e.class]; end
r157 = Hash.new { |hh, kk| hh[kk] = [kk] }
r157[1] = "a"
r157["b"] = 2
begin; p [157, (r157.public_send(:keys)), r157]; rescue => e; p [157, :raised, e.class]; end
r158 = {"a" => 1, "b" => 2}
begin; p [158, (r158.method(:keys).call), r158]; rescue => e; p [158, :raised, e.class]; end
r159 = Hash.new(-1)
r159[1] = 10
r159[2] = 20
begin; p [159, (r159.instance_variables), r159]; rescue => e; p [159, :raised, e.class]; end
r160 = Hash.new(0)
r160["a"] = 1
r160["b"] = 2
begin; p [160, (r160.equal?(r160)), r160]; rescue => e; p [160, :raised, e.class]; end
r161 = {1 => "x", 2 => "y"}
begin; p [161, (r161 =~ /a/), r161]; rescue => e; p [161, :raised, e.class]; end
r162 = {"a" => "x", "b" => "y"}
begin; p [162, (!r162), r162]; rescue => e; p [162, :raised, e.class]; end
r163 = {1 => 10}
r163.clear
begin; p [163, (r163.to_a.transpose), r163]; rescue => e; p [163, :raised, e.class]; end
r164 = {a: 1, b: 2}
begin; p [164, (r164.keys.sort_by(&:to_s)), r164]; rescue => e; p [164, :raised, e.class]; end
r165 = {"a" => 1, "b" => "x"}
begin; p [165, (r165.values.map(&:to_s)), r165]; rescue => e; p [165, :raised, e.class]; end
r166 = Hash.new { |hh, kk| hh[kk] = [kk] }
r166[1] = "a"
r166["b"] = 2
begin; p [166, (r166.sort_by { |k, v| v.to_s }.to_h), r166]; rescue => e; p [166, :raised, e.class]; end
r167 = {"a" => 1, "b" => 2}
begin; p [167, (r167.lazy.map { |k, v| k }.to_a), r167]; rescue => e; p [167, :raised, e.class]; end
r168 = Hash.new(-1)
r168[1] = 10
r168[2] = 20
begin; p [168, (r168.each_entry.to_a), r168]; rescue => e; p [168, :raised, e.class]; end
r169 = Hash.new(0)
r169["a"] = 1
r169["b"] = 2
begin; p [169, (r169.min_by { |kv| kv.to_s }), r169]; rescue => e; p [169, :raised, e.class]; end
r170 = {1 => "x", 2 => "y"}
begin; p [170, (r170.filter_map { |kv| kv }), r170]; rescue => e; p [170, :raised, e.class]; end
r171 = {"a" => "x", "b" => "y"}
begin; p [171, (Hash[r171.to_a]), r171]; rescue => e; p [171, :raised, e.class]; end
r172 = {1 => 10}
r172.clear
begin; p [172, (r172.to_a.to_h), r172]; rescue => e; p [172, :raised, e.class]; end
r173 = {a: 1, b: 2}
begin; p [173, (r173.key?(:a.to_s)), r173]; rescue => e; p [173, :raised, e.class]; end
r174 = {"a" => 1, "b" => "x"}
begin; p [174, (case r174
in {} then :e
else :ne end), r174]; rescue => e; p [174, :raised, e.class]; end
r175 = Hash.new { |hh, kk| hh[kk] = [kk] }
r175[1] = "a"
r175["b"] = 2
begin; p [175, ((r175 in {})), r175]; rescue => e; p [175, :raised, e.class]; end
r176 = {"a" => 1, "b" => 2}
begin; p [176, (r176.dig("a", 0)), r176]; rescue => e; p [176, :raised, e.class]; end
r177 = Hash.new(-1)
r177[1] = 10
r177[2] = 20
begin; p [177, (r177.fetch(1).class), r177]; rescue => e; p [177, :raised, e.class]; end
r178 = Hash.new(0)
r178["a"] = 1
r178["b"] = 2
begin; p [178, (r178["a"].class), r178]; rescue => e; p [178, :raised, e.class]; end
r179 = {1 => "x", 2 => "y"}
begin; p [179, (r179[9].class), r179]; rescue => e; p [179, :raised, e.class]; end
r180 = {"a" => "x", "b" => "y"}
begin; p [180, (r180["a"] ||= "w"), r180]; rescue => e; p [180, :raised, e.class]; end
r181 = {1 => 10}
r181.clear
begin; p [181, (r181[9] ||= 30), r181]; rescue => e; p [181, :raised, e.class]; end
r182 = {a: 1, b: 2}
begin; p [182, ((r182[:z] ||= 3; r182)), r182]; rescue => e; p [182, :raised, e.class]; end
r183 = {"a" => 1, "b" => "x"}
begin; p [183, (r183.count("a")), r183]; rescue => e; p [183, :raised, e.class]; end
r184 = Hash.new { |hh, kk| hh[kk] = [kk] }
r184[1] = "a"
r184["b"] = 2
begin; p [184, (r184.find_index([1, "a"])), r184]; rescue => e; p [184, :raised, e.class]; end
