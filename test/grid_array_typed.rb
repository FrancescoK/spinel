# frozen_string_literal: true
# Every Array method on the typed arrays (sp_IntArray, sp_FloatArray,
# sp_StrArray; three, one and no elements) with a poly array as the
# control, one probe per call, the receivers taken in turn.
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
class K
  include Comparable
  attr_reader :v
  def initialize(v) = @v = v
  def <=>(o) = o.is_a?(K) ? v <=> o.v : nil
  def ==(o) = o.is_a?(K) && v == o.v
  def eql?(o) = self == o
  def hash = v.hash
  def inspect = "K#{v}"
  def to_s = "k#{v}"
  def +(o) = K.new(v + o.v)
  def coerce(n) = [K.new(n), self]
end
r0 = [3, 1, 2]
begin; p [0, (r0 & [1]), r0]; rescue => e; p [0, :raised, e.class]; end
r1 = [2.5, 1.5, 3.0]
begin; p [1, (r1 & []), r1]; rescue => e; p [1, :raised, e.class]; end
r2 = ["b", "a", "c"]
begin; p [2, (r2 * 2), r2]; rescue => e; p [2, :raised, e.class]; end
r3 = [5]
r3.clear
begin; p [3, (r3 * 0), r3]; rescue => e; p [3, :raised, e.class]; end
r4 = [2.5]
r4.clear
begin; p [4, (r4 * ","), r4]; rescue => e; p [4, :raised, e.class]; end
r5 = ["b"]
r5.clear
begin; p [5, (r5 * -1), r5]; rescue => e; p [5, :raised, e.class]; end
r6 = [5]
begin; p [6, (r6 + [4]), r6]; rescue => e; p [6, :raised, e.class]; end
r7 = [3, 1, 2]
begin; p [7, (r7 - [1]), r7]; rescue => e; p [7, :raised, e.class]; end
r8 = [2.5, 1.5, 3.0]
begin; p [8, (r8 << 4.5), r8]; rescue => e; p [8, :raised, e.class]; end
r9 = ["b", "a", "c"]
begin; p [9, (r9 <=> ["a"]), r9]; rescue => e; p [9, :raised, e.class]; end
r10 = [5]
r10.clear
begin; p [10, (r10 <=> r10.dup), r10]; rescue => e; p [10, :raised, e.class]; end
r11 = [2.5]
r11.clear
begin; p [11, (r11 <=> 1), r11]; rescue => e; p [11, :raised, e.class]; end
r12 = ["b"]
r12.clear
begin; p [12, (r12 == r12.dup), r12]; rescue => e; p [12, :raised, e.class]; end
r13 = [3, 1, 2, nil]
begin; p [13, (r13 == 1), r13]; rescue => e; p [13, :raised, e.class]; end
r14 = [3, 1, 2]
begin; p [14, (r14 != []), r14]; rescue => e; p [14, :raised, e.class]; end
r15 = [2.5, 1.5, 3.0]
begin; p [15, (r15 | [4.5]), r15]; rescue => e; p [15, :raised, e.class]; end
r16 = ["b", "a", "c"]
begin; p [16, (r16 | r16), r16]; rescue => e; p [16, :raised, e.class]; end
r17 = [5]
r17.clear
begin; p [17, (r17[0]), r17]; rescue => e; p [17, :raised, e.class]; end
r18 = [2.5]
r18.clear
begin; p [18, (r18[-1]), r18]; rescue => e; p [18, :raised, e.class]; end
r19 = ["b"]
r19.clear
begin; p [19, (r19[1]), r19]; rescue => e; p [19, :raised, e.class]; end
r20 = [3, 1, 2, nil]
begin; p [20, (r20[-9]), r20]; rescue => e; p [20, :raised, e.class]; end
r21 = [3, 1, 2]
begin; p [21, (r21[0, 2]), r21]; rescue => e; p [21, :raised, e.class]; end
r22 = [2.5, 1.5, 3.0]
begin; p [22, (r22[1..]), r22]; rescue => e; p [22, :raised, e.class]; end
r23 = ["b", "a", "c"]
begin; p [23, (r23[..-2]), r23]; rescue => e; p [23, :raised, e.class]; end
r24 = [5]
r24.clear
begin; p [24, (r24[5, 1]), r24]; rescue => e; p [24, :raised, e.class]; end
r25 = [2.5]
r25.clear
begin; p [25, (r25[0...0]), r25]; rescue => e; p [25, :raised, e.class]; end
r26 = [5]
begin; p [26, (r26[-1, 9]), r26]; rescue => e; p [26, :raised, e.class]; end
r27 = [3, 1, 2]
begin; p [27, (r27["a"]), r27]; rescue => e; p [27, :raised, e.class]; end
r28 = ["b", "a", "c"]
begin; p [28, (r28[0] = "d"), r28]; rescue => e; p [28, :raised, e.class]; end
r29 = [5]
r29.clear
begin; p [29, (r29[5] = 4), r29]; rescue => e; p [29, :raised, e.class]; end
r30 = [2.5]
r30.clear
begin; p [30, (r30[0, 2] = [4.5]), r30]; rescue => e; p [30, :raised, e.class]; end
r31 = ["b"]
r31.clear
begin; p [31, (r31[-9] = "d"), r31]; rescue => e; p [31, :raised, e.class]; end
r32 = [3, 1, 2, nil]
begin; p [32, (r32.at(0)), r32]; rescue => e; p [32, :raised, e.class]; end
r33 = [3, 1, 2]
begin; p [33, (r33.at(-1)), r33]; rescue => e; p [33, :raised, e.class]; end
r34 = [2.5, 1.5, 3.0]
begin; p [34, (r34.at(9)), r34]; rescue => e; p [34, :raised, e.class]; end
r35 = ["b", "a", "c"]
begin; p [35, (r35.fetch(0)), r35]; rescue => e; p [35, :raised, e.class]; end
r36 = [5]
r36.clear
begin; p [36, (r36.fetch(9)), r36]; rescue => e; p [36, :raised, e.class]; end
r37 = [2.5]
r37.clear
begin; p [37, (r37.fetch(9, :d)), r37]; rescue => e; p [37, :raised, e.class]; end
r38 = [5]
begin; p [38, (r38.fetch(-1)), r38]; rescue => e; p [38, :raised, e.class]; end
r39 = [3, 1, 2, nil]
begin; p [39, (r39.dig(0)), r39]; rescue => e; p [39, :raised, e.class]; end
r40 = [3, 1, 2]
begin; p [40, (r40.first), r40]; rescue => e; p [40, :raised, e.class]; end
r41 = [2.5, 1.5, 3.0]
begin; p [41, (r41.first(2)), r41]; rescue => e; p [41, :raised, e.class]; end
r42 = ["b", "a", "c"]
begin; p [42, (r42.first(0)), r42]; rescue => e; p [42, :raised, e.class]; end
r43 = [5]
r43.clear
begin; p [43, (r43.first(-1)), r43]; rescue => e; p [43, :raised, e.class]; end
r44 = ["b"]
r44.clear
begin; p [44, (r44.last(2)), r44]; rescue => e; p [44, :raised, e.class]; end
r45 = [5]
begin; p [45, (r45.last(9)), r45]; rescue => e; p [45, :raised, e.class]; end
r46 = [3, 1, 2, nil]
begin; p [46, (r46.values_at(0, 2, 9)), r46]; rescue => e; p [46, :raised, e.class]; end
r47 = [3, 1, 2]
begin; p [47, (r47.values_at(0..1)), r47]; rescue => e; p [47, :raised, e.class]; end
r48 = [2.5, 1.5, 3.0]
begin; p [48, (r48.fetch_values(0)), r48]; rescue => e; p [48, :raised, e.class]; end
r49 = ["b", "a", "c"]
begin; p [49, (r49.fetch_values(9)), r49]; rescue => e; p [49, :raised, e.class]; end
r50 = [5]
r50.clear
begin; p [50, (r50.slice(1, 2)), r50]; rescue => e; p [50, :raised, e.class]; end
r51 = ["b"]
r51.clear
begin; p [51, (r51.slice!(0)), r51]; rescue => e; p [51, :raised, e.class]; end
r52 = [5]
begin; p [52, (r52.slice!(1, 2)), r52]; rescue => e; p [52, :raised, e.class]; end
r53 = [3, 1, 2, nil]
begin; p [53, (r53.slice!(9)), r53]; rescue => e; p [53, :raised, e.class]; end
r54 = [3, 1, 2]
begin; p [54, (r54.assoc(1)), r54]; rescue => e; p [54, :raised, e.class]; end
r55 = [2.5, 1.5, 3.0]
begin; p [55, (r55.rassoc(1.5)), r55]; rescue => e; p [55, :raised, e.class]; end
r56 = ["b", "a", "c"]
begin; p [56, (r56.all?), r56]; rescue => e; p [56, :raised, e.class]; end
r57 = [2.5]
r57.clear
begin; p [57, (r57.all?(2.5)), r57]; rescue => e; p [57, :raised, e.class]; end
r58 = ["b"]
r58.clear
begin; p [58, (r58.any?), r58]; rescue => e; p [58, :raised, e.class]; end
r59 = [5]
begin; p [59, (r59.any? { |x| x == 5 }), r59]; rescue => e; p [59, :raised, e.class]; end
r60 = [3, 1, 2, nil]
begin; p [60, (r60.any?(9)), r60]; rescue => e; p [60, :raised, e.class]; end
r61 = [3, 1, 2]
begin; p [61, (r61.none?), r61]; rescue => e; p [61, :raised, e.class]; end
r62 = [2.5, 1.5, 3.0]
begin; p [62, (r62.none? { |x| x == 1.5 }), r62]; rescue => e; p [62, :raised, e.class]; end
r63 = ["b", "a", "c"]
begin; p [63, (r63.one?), r63]; rescue => e; p [63, :raised, e.class]; end
r64 = [2.5]
r64.clear
begin; p [64, (r64.include?(2.5)), r64]; rescue => e; p [64, :raised, e.class]; end
r65 = ["b"]
r65.clear
begin; p [65, (r65.include?("z")), r65]; rescue => e; p [65, :raised, e.class]; end
r66 = [5]
begin; p [66, (r66.include?(nil)), r66]; rescue => e; p [66, :raised, e.class]; end
r67 = [3, 1, 2, nil]
begin; p [67, (r67.member?(1)), r67]; rescue => e; p [67, :raised, e.class]; end
r68 = [3, 1, 2]
begin; p [68, (r68.index(1)), r68]; rescue => e; p [68, :raised, e.class]; end
r69 = [2.5, 1.5, 3.0]
begin; p [69, (r69.index(9.0)), r69]; rescue => e; p [69, :raised, e.class]; end
r70 = [5]
r70.clear
begin; p [70, (r70.find_index(5)), r70]; rescue => e; p [70, :raised, e.class]; end
r71 = [2.5]
r71.clear
begin; p [71, (r71.rindex(2.5)), r71]; rescue => e; p [71, :raised, e.class]; end
r72 = ["b"]
r72.clear
begin; p [72, (r72.rindex { |x| x == "b" }), r72]; rescue => e; p [72, :raised, e.class]; end
r73 = [5]
begin; p [73, (r73.find { |x| x == 5 }), r73]; rescue => e; p [73, :raised, e.class]; end
r74 = [3, 1, 2, nil]
begin; p [74, (r74.detect { |x| x == 9 }), r74]; rescue => e; p [74, :raised, e.class]; end
r75 = [3, 1, 2]
begin; p [75, (r75.rfind { |x| x == 1 }), r75]; rescue => e; p [75, :raised, e.class]; end
r76 = ["b", "a", "c"]
begin; p [76, (r76.count("a")), r76]; rescue => e; p [76, :raised, e.class]; end
r77 = [5]
r77.clear
begin; p [77, (r77.count { |x| x == 5 }), r77]; rescue => e; p [77, :raised, e.class]; end
r78 = [2.5]
r78.clear
begin; p [78, (r78.empty?), r78]; rescue => e; p [78, :raised, e.class]; end
r79 = ["b"]
r79.clear
begin; p [79, (r79.length), r79]; rescue => e; p [79, :raised, e.class]; end
r80 = [5]
begin; p [80, (r80.size), r80]; rescue => e; p [80, :raised, e.class]; end
r81 = [3, 1, 2, nil]
begin; p [81, (r81.intersect?([1])), r81]; rescue => e; p [81, :raised, e.class]; end
r82 = [3, 1, 2]
begin; p [82, (r82.eql?(r82.dup)), r82]; rescue => e; p [82, :raised, e.class]; end
r83 = ["b", "a", "c"]
begin; p [83, (r83.bsearch { |x| x >= "a" }), r83]; rescue => e; p [83, :raised, e.class]; end
r84 = [5]
r84.clear
begin; p [84, (r84.bsearch_index { |x| x >= 5 }), r84]; rescue => e; p [84, :raised, e.class]; end
r85 = [2.5]
r85.clear
begin; p [85, (r85.append(4.5)), r85]; rescue => e; p [85, :raised, e.class]; end
r86 = ["b"]
r86.clear
begin; p [86, (r86.push("d", "d")), r86]; rescue => e; p [86, :raised, e.class]; end
r87 = [5]
begin; p [87, (r87.push), r87]; rescue => e; p [87, :raised, e.class]; end
r88 = [3, 1, 2, nil]
begin; p [88, (r88.prepend(4)), r88]; rescue => e; p [88, :raised, e.class]; end
r89 = [2.5, 1.5, 3.0]
begin; p [89, (r89.insert(1, 4.5)), r89]; rescue => e; p [89, :raised, e.class]; end
r90 = ["b", "a", "c"]
begin; p [90, (r90.insert(9, "d")), r90]; rescue => e; p [90, :raised, e.class]; end
r91 = [5]
r91.clear
begin; p [91, (r91.insert(-2, 4)), r91]; rescue => e; p [91, :raised, e.class]; end
r92 = [2.5]
r92.clear
begin; p [92, (r92.pop), r92]; rescue => e; p [92, :raised, e.class]; end
r93 = ["b"]
r93.clear
begin; p [93, (r93.pop(2)), r93]; rescue => e; p [93, :raised, e.class]; end
r94 = [5]
begin; p [94, (r94.shift), r94]; rescue => e; p [94, :raised, e.class]; end
r95 = [3, 1, 2, nil]
begin; p [95, (r95.shift(2)), r95]; rescue => e; p [95, :raised, e.class]; end
r96 = [2.5, 1.5, 3.0]
begin; p [96, (r96.concat([4.5])), r96]; rescue => e; p [96, :raised, e.class]; end
r97 = ["b", "a", "c"]
begin; p [97, (r97.concat(["d"], ["a"])), r97]; rescue => e; p [97, :raised, e.class]; end
r98 = [5]
r98.clear
begin; p [98, (r98.replace([4])), r98]; rescue => e; p [98, :raised, e.class]; end
r99 = [2.5]
r99.clear
begin; p [99, (r99.delete(2.5)), r99]; rescue => e; p [99, :raised, e.class]; end
r100 = ["b"]
r100.clear
begin; p [100, (r100.delete("z")), r100]; rescue => e; p [100, :raised, e.class]; end
r101 = [5]
begin; p [101, (r101.delete(9) { :nf }), r101]; rescue => e; p [101, :raised, e.class]; end
r102 = [3, 1, 2]
begin; p [102, (r102.delete_at(9)), r102]; rescue => e; p [102, :raised, e.class]; end
r103 = [2.5, 1.5, 3.0]
begin; p [103, (r103.delete_at(-1)), r103]; rescue => e; p [103, :raised, e.class]; end
r104 = ["b", "a", "c"]
begin; p [104, (r104.delete_if { |x| x == "a" }), r104]; rescue => e; p [104, :raised, e.class]; end
r105 = [5]
r105.clear
begin; p [105, (r105.keep_if { |x| x == 5 }), r105]; rescue => e; p [105, :raised, e.class]; end
r106 = [2.5]
r106.clear
begin; p [106, (r106.reject! { |x| x == 9.0 }), r106]; rescue => e; p [106, :raised, e.class]; end
r107 = ["b"]
r107.clear
begin; p [107, (r107.select! { |x| true }), r107]; rescue => e; p [107, :raised, e.class]; end
r108 = [3, 1, 2, nil]
begin; p [108, (r108.map! { |x| x }), r108]; rescue => e; p [108, :raised, e.class]; end
r109 = [3, 1, 2]
begin; p [109, (r109.collect! { |x| 4 }), r109]; rescue => e; p [109, :raised, e.class]; end
r110 = [2.5, 1.5, 3.0]
begin; p [110, (r110.fill(4.5)), r110]; rescue => e; p [110, :raised, e.class]; end
r111 = ["b", "a", "c"]
begin; p [111, (r111.fill("d", 1)), r111]; rescue => e; p [111, :raised, e.class]; end
r112 = [5]
r112.clear
begin; p [112, (r112.fill(4, 1, 1)), r112]; rescue => e; p [112, :raised, e.class]; end
r113 = [2.5]
r113.clear
begin; p [113, (r113.fill { |i| 4.5 }), r113]; rescue => e; p [113, :raised, e.class]; end
r114 = ["b"]
r114.clear
begin; p [114, (r114.compact!), r114]; rescue => e; p [114, :raised, e.class]; end
r115 = [3, 1, 2, nil]
begin; p [115, (r115.uniq!), r115]; rescue => e; p [115, :raised, e.class]; end
r116 = [3, 1, 2]
begin; p [116, (r116.reverse!), r116]; rescue => e; p [116, :raised, e.class]; end
r117 = [2.5, 1.5, 3.0]
begin; p [117, (r117.rotate!), r117]; rescue => e; p [117, :raised, e.class]; end
r118 = ["b", "a", "c"]
begin; p [118, (r118.rotate!(-1)), r118]; rescue => e; p [118, :raised, e.class]; end
r119 = [5]
r119.clear
begin; p [119, (r119.sort!), r119]; rescue => e; p [119, :raised, e.class]; end
r120 = [2.5]
r120.clear
begin; p [120, (r120.sort! { |a, b| b <=> a }), r120]; rescue => e; p [120, :raised, e.class]; end
r121 = [5]
begin; p [121, (r121.shuffle!.size), r121]; rescue => e; p [121, :raised, e.class]; end
r122 = [3, 1, 2, nil]
begin; p [122, (r122.freeze), r122]; rescue => e; p [122, :raised, e.class]; end
r123 = [3, 1, 2]
begin; p [123, (r123.frozen?), r123]; rescue => e; p [123, :raised, e.class]; end
r124 = [2.5, 1.5, 3.0]
begin; p [124, (r124.freeze << 4.5), r124]; rescue => e; p [124, :raised, e.class]; end
r125 = ["b", "a", "c"]
begin; p [125, (r125.compact), r125]; rescue => e; p [125, :raised, e.class]; end
r126 = [5]
r126.clear
begin; p [126, (r126.flatten), r126]; rescue => e; p [126, :raised, e.class]; end
r127 = [2.5]
r127.clear
begin; p [127, (r127.flatten(1)), r127]; rescue => e; p [127, :raised, e.class]; end
r128 = [5]
begin; p [128, (r128.uniq { |x| x.class }), r128]; rescue => e; p [128, :raised, e.class]; end
r129 = [3, 1, 2, nil]
begin; p [129, (r129.reverse), r129]; rescue => e; p [129, :raised, e.class]; end
r130 = [3, 1, 2]
begin; p [130, (r130.rotate), r130]; rescue => e; p [130, :raised, e.class]; end
r131 = [2.5, 1.5, 3.0]
begin; p [131, (r131.rotate(2)), r131]; rescue => e; p [131, :raised, e.class]; end
r132 = ["b", "a", "c"]
begin; p [132, (r132.rotate(-1)), r132]; rescue => e; p [132, :raised, e.class]; end
r133 = [5]
r133.clear
begin; p [133, (r133.sort), r133]; rescue => e; p [133, :raised, e.class]; end
r134 = ["b"]
r134.clear
begin; p [134, (r134.sort_by { |x| x }), r134]; rescue => e; p [134, :raised, e.class]; end
r135 = [5]
begin; p [135, (r135.min), r135]; rescue => e; p [135, :raised, e.class]; end
r136 = [3, 1, 2, nil]
begin; p [136, (r136.max), r136]; rescue => e; p [136, :raised, e.class]; end
r137 = [3, 1, 2]
begin; p [137, (r137.min(2)), r137]; rescue => e; p [137, :raised, e.class]; end
r138 = [2.5, 1.5, 3.0]
begin; p [138, (r138.max(2)), r138]; rescue => e; p [138, :raised, e.class]; end
r139 = ["b", "a", "c"]
begin; p [139, (r139.minmax), r139]; rescue => e; p [139, :raised, e.class]; end
r140 = [5]
r140.clear
begin; p [140, (r140.min { |a, b| b <=> a }), r140]; rescue => e; p [140, :raised, e.class]; end
r141 = ["b"]
r141.clear
begin; p [141, (r141.min_by { |x| x }), r141]; rescue => e; p [141, :raised, e.class]; end
r142 = [5]
begin; p [142, (r142.minmax_by { |x| x }), r142]; rescue => e; p [142, :raised, e.class]; end
r143 = [3, 1, 2, nil]
begin; p [143, (r143.sum), r143]; rescue => e; p [143, :raised, e.class]; end
r144 = [3, 1, 2]
begin; p [144, (r144.sum(0.0)), r144]; rescue => e; p [144, :raised, e.class]; end
r145 = [2.5, 1.5, 3.0]
begin; p [145, (r145.sum { |x| 1 }), r145]; rescue => e; p [145, :raised, e.class]; end
r146 = ["b", "a", "c"]
begin; p [146, (r146.take(2)), r146]; rescue => e; p [146, :raised, e.class]; end
r147 = [2.5]
r147.clear
begin; p [147, (r147.take(-1)), r147]; rescue => e; p [147, :raised, e.class]; end
r148 = ["b"]
r148.clear
begin; p [148, (r148.drop(1)), r148]; rescue => e; p [148, :raised, e.class]; end
r149 = [5]
begin; p [149, (r149.drop(9)), r149]; rescue => e; p [149, :raised, e.class]; end
r150 = [3, 1, 2, nil]
begin; p [150, (r150.take_while { |x| x != 9 }), r150]; rescue => e; p [150, :raised, e.class]; end
r151 = [3, 1, 2]
begin; p [151, (r151.drop_while { |x| x == 1 }), r151]; rescue => e; p [151, :raised, e.class]; end
r152 = [2.5, 1.5, 3.0]
begin; p [152, (r152.map { |x| x }), r152]; rescue => e; p [152, :raised, e.class]; end
r153 = [5]
r153.clear
begin; p [153, (r153.flat_map { |x| [x, x] }), r153]; rescue => e; p [153, :raised, e.class]; end
r154 = [2.5]
r154.clear
begin; p [154, (r154.collect_concat { |x| [x] }), r154]; rescue => e; p [154, :raised, e.class]; end
r155 = ["b"]
r155.clear
begin; p [155, (r155.filter_map { |x| x if x == "b" }), r155]; rescue => e; p [155, :raised, e.class]; end
r156 = [5]
begin; p [156, (r156.select { |x| x == 5 }), r156]; rescue => e; p [156, :raised, e.class]; end
r157 = [3, 1, 2, nil]
begin; p [157, (r157.filter { |x| x != 1 }), r157]; rescue => e; p [157, :raised, e.class]; end
r158 = [3, 1, 2]
begin; p [158, (r158.reject { |x| x == 1 }), r158]; rescue => e; p [158, :raised, e.class]; end
r159 = [2.5, 1.5, 3.0]
begin; p [159, (r159.find_all { |x| true }), r159]; rescue => e; p [159, :raised, e.class]; end
r160 = [5]
r160.clear
begin; p [160, (r160.grep(5)), r160]; rescue => e; p [160, :raised, e.class]; end
r161 = [2.5]
r161.clear
begin; p [161, (r161.grep_v(2.5)), r161]; rescue => e; p [161, :raised, e.class]; end
r162 = ["b"]
r162.clear
begin; p [162, (r162.grep(Integer)), r162]; rescue => e; p [162, :raised, e.class]; end
r163 = [5]
begin; p [163, (r163.grep(String) { |x| x }), r163]; rescue => e; p [163, :raised, e.class]; end
r164 = [3, 1, 2, nil]
begin; p [164, (r164.group_by { |x| x }), r164]; rescue => e; p [164, :raised, e.class]; end
r165 = [3, 1, 2]
begin; p [165, (r165.chunk_while { |a, b| a == b }.to_a), r165]; rescue => e; p [165, :raised, e.class]; end
r166 = ["b", "a", "c"]
begin; p [166, (r166.slice_when { |a, b| a != b }.to_a), r166]; rescue => e; p [166, :raised, e.class]; end
r167 = [5]
r167.clear
begin; p [167, (r167.chunk { |x| x == 5 }.to_a), r167]; rescue => e; p [167, :raised, e.class]; end
r168 = [2.5]
r168.clear
begin; p [168, (r168.slice_before { |x| x == 2.5 }.to_a), r168]; rescue => e; p [168, :raised, e.class]; end
r169 = ["b"]
r169.clear
begin; p [169, (r169.slice_after { |x| x == "b" }.to_a), r169]; rescue => e; p [169, :raised, e.class]; end
r170 = [5]
begin; p [170, (r170.each_slice(2).to_a), r170]; rescue => e; p [170, :raised, e.class]; end
r171 = [3, 1, 2, nil]
begin; p [171, (r171.each_cons(2).to_a), r171]; rescue => e; p [171, :raised, e.class]; end
r172 = [3, 1, 2]
begin; p [172, (r172.each_slice(2) { |s| s }), r172]; rescue => e; p [172, :raised, e.class]; end
r173 = ["b", "a", "c"]
begin; p [173, (r173.each_with_index.to_a), r173]; rescue => e; p [173, :raised, e.class]; end
r174 = [5]
r174.clear
begin; p [174, (r174.each_with_index.map { |x, i| i }), r174]; rescue => e; p [174, :raised, e.class]; end
r175 = [2.5]
r175.clear
begin; p [175, (r175.each_with_object([]) { |x, acc| acc << x }), r175]; rescue => e; p [175, :raised, e.class]; end
r176 = ["b"]
r176.clear
begin; p [176, (r176.each.with_index(1).to_a), r176]; rescue => e; p [176, :raised, e.class]; end
r177 = [5]
begin; p [177, (r177.inject { |a, b| a }), r177]; rescue => e; p [177, :raised, e.class]; end
r178 = [3, 1, 2, nil]
begin; p [178, (r178.inject(:+)), r178]; rescue => e; p [178, :raised, e.class]; end
r179 = [2.5, 1.5, 3.0]
begin; p [179, (r179.inject(4.5) { |a, x| a }), r179]; rescue => e; p [179, :raised, e.class]; end
r180 = ["b", "a", "c"]
begin; p [180, (r180.tally), r180]; rescue => e; p [180, :raised, e.class]; end
r181 = [5]
r181.clear
begin; p [181, (r181.zip([1, 2])), r181]; rescue => e; p [181, :raised, e.class]; end
r182 = [2.5]
r182.clear
begin; p [182, (r182.zip(r182)), r182]; rescue => e; p [182, :raised, e.class]; end
r183 = ["b"]
r183.clear
begin; p [183, (r183.product([1])), r183]; rescue => e; p [183, :raised, e.class]; end
r184 = [5]
begin; p [184, (r184.product), r184]; rescue => e; p [184, :raised, e.class]; end
r185 = [3, 1, 2]
begin; p [185, (r185.combination(2).to_a), r185]; rescue => e; p [185, :raised, e.class]; end
r186 = [2.5, 1.5, 3.0]
begin; p [186, (r186.permutation(2).to_a), r186]; rescue => e; p [186, :raised, e.class]; end
r187 = ["b", "a", "c"]
begin; p [187, (r187.repeated_combination(2).to_a), r187]; rescue => e; p [187, :raised, e.class]; end
r188 = [5]
r188.clear
begin; p [188, (r188.repeated_permutation(1).to_a), r188]; rescue => e; p [188, :raised, e.class]; end
r189 = [2.5]
r189.clear
begin; p [189, (r189.combination(0).to_a), r189]; rescue => e; p [189, :raised, e.class]; end
r190 = ["b"]
r190.clear
begin; p [190, (r190.cycle(2).to_a), r190]; rescue => e; p [190, :raised, e.class]; end
r191 = [5]
begin; p [191, (r191.cycle(2) { |x| x }), r191]; rescue => e; p [191, :raised, e.class]; end
r192 = [3, 1, 2]
begin; p [192, (r192.to_h), r192]; rescue => e; p [192, :raised, e.class]; end
r193 = [2.5, 1.5, 3.0]
begin; p [193, (r193.to_h { |x| [x, 1] }), r193]; rescue => e; p [193, :raised, e.class]; end
r194 = ["b", "a", "c"]
begin; p [194, (r194.each_entry.to_a), r194]; rescue => e; p [194, :raised, e.class]; end
r195 = [5]
r195.clear
begin; p [195, (r195.join), r195]; rescue => e; p [195, :raised, e.class]; end
r196 = [2.5]
r196.clear
begin; p [196, (r196.join("-")), r196]; rescue => e; p [196, :raised, e.class]; end
r197 = ["b"]
r197.clear
begin; p [197, (r197.to_s), r197]; rescue => e; p [197, :raised, e.class]; end
r198 = [3, 1, 2, nil]
begin; p [198, (r198.to_a), r198]; rescue => e; p [198, :raised, e.class]; end
r199 = [3, 1, 2]
begin; p [199, (r199.to_ary), r199]; rescue => e; p [199, :raised, e.class]; end
r200 = [2.5, 1.5, 3.0]
begin; p [200, (r200.entries), r200]; rescue => e; p [200, :raised, e.class]; end
r201 = ["b", "a", "c"]
begin; p [201, (r201.to_set.size), r201]; rescue => e; p [201, :raised, e.class]; end
r202 = [5]
r202.clear
begin; p [202, (r202.lazy.map { |x| x }.to_a), r202]; rescue => e; p [202, :raised, e.class]; end
r203 = [2.5]
r203.clear
begin; p [203, (r203.union([4.5])), r203]; rescue => e; p [203, :raised, e.class]; end
r204 = ["b"]
r204.clear
begin; p [204, (r204.difference(["b"])), r204]; rescue => e; p [204, :raised, e.class]; end
r205 = [3, 1, 2, nil]
begin; p [205, (r205.difference), r205]; rescue => e; p [205, :raised, e.class]; end
r206 = [3, 1, 2]
begin; p [206, (r206.pack("C*")), r206]; rescue => e; p [206, :raised, e.class]; end
r207 = ["b", "a", "c"]
begin; p [207, (r207.pack("a*")), r207]; rescue => e; p [207, :raised, e.class]; end
r208 = ["b", "a", "c"]
begin; p [208, (r208.pack("E*")), r208]; rescue => e; p [208, :raised, e.class]; end
r209 = [5]
r209.clear
begin; p [209, (r209.deconstruct), r209]; rescue => e; p [209, :raised, e.class]; end
r210 = [2.5]
r210.clear
begin; p [210, (r210.hash == r210.dup.hash), r210]; rescue => e; p [210, :raised, e.class]; end
r211 = [5]
begin; p [211, (r211.shuffle.size), r211]; rescue => e; p [211, :raised, e.class]; end
r212 = [3, 1, 2, nil]
begin; p [212, (r212.dup), r212]; rescue => e; p [212, :raised, e.class]; end
r213 = [3, 1, 2]
begin; p [213, (r213.clone), r213]; rescue => e; p [213, :raised, e.class]; end
r214 = [2.5, 1.5, 3.0]
begin; p [214, (r214.dup.frozen?), r214]; rescue => e; p [214, :raised, e.class]; end
r215 = ["b", "a", "c"]
begin; p [215, (r215.each { |x| x }), r215]; rescue => e; p [215, :raised, e.class]; end
r216 = [5]
r216.clear
begin; p [216, (r216.each_index { |i| i }), r216]; rescue => e; p [216, :raised, e.class]; end
r217 = ["b"]
r217.clear
begin; p [217, (r217.reverse_each { |x| x }), r217]; rescue => e; p [217, :raised, e.class]; end
r218 = [5]
begin; p [218, (r218.reverse_each.to_a), r218]; rescue => e; p [218, :raised, e.class]; end
r219 = [3, 1, 2, nil]
begin; p [219, (r219.each.next), r219]; rescue => e; p [219, :raised, e.class]; end
r220 = [3, 1, 2]
begin; p [220, (r220.map.with_index { |x, i| i }), r220]; rescue => e; p [220, :raised, e.class]; end
r221 = [2.5, 1.5, 3.0]
begin; p [221, (r221.each_with_index { |x, i| x }), r221]; rescue => e; p [221, :raised, e.class]; end
r222 = ["b", "a", "c"]
begin; p [222, (r222.class), r222]; rescue => e; p [222, :raised, e.class]; end
r223 = [5]
r223.clear
begin; p [223, (r223.nil?), r223]; rescue => e; p [223, :raised, e.class]; end
r224 = ["b"]
r224.clear
begin; p [224, (r224.is_a?(Enumerable)), r224]; rescue => e; p [224, :raised, e.class]; end
r225 = [5]
begin; p [225, (r225.respond_to?(:each)), r225]; rescue => e; p [225, :raised, e.class]; end
r226 = [3, 1, 2, nil]
begin; p [226, (r226.itself), r226]; rescue => e; p [226, :raised, e.class]; end
r227 = [3, 1, 2]
begin; p [227, (r227.tap { |q| q }), r227]; rescue => e; p [227, :raised, e.class]; end
r228 = [2.5, 1.5, 3.0]
begin; p [228, (r228.then { |q| q.size }), r228]; rescue => e; p [228, :raised, e.class]; end
r229 = ["b", "a", "c"]
begin; p [229, (r229.send(:size)), r229]; rescue => e; p [229, :raised, e.class]; end
r230 = [2.5]
r230.clear
begin; p [230, (r230.method(:size).call), r230]; rescue => e; p [230, :raised, e.class]; end
r231 = ["b"]
r231.clear
begin; p [231, (r231.instance_variables), r231]; rescue => e; p [231, :raised, e.class]; end
r232 = [5]
begin; p [232, (r232.equal?(r232)), r232]; rescue => e; p [232, :raised, e.class]; end
r233 = [3, 1, 2, nil]
begin; p [233, (r233.object_id == r233.object_id), r233]; rescue => e; p [233, :raised, e.class]; end
r234 = [3, 1, 2]
begin; p [234, (r234.frozen?), r234]; rescue => e; p [234, :raised, e.class]; end
r235 = [2.5, 1.5, 3.0]
begin; p [235, (r235 =~ /a/), r235]; rescue => e; p [235, :raised, e.class]; end
r236 = [5]
r236.clear
begin; p [236, (Array(r236)), r236]; rescue => e; p [236, :raised, e.class]; end
r237 = ["b"]
r237.clear
begin; p [237, ([r237, r237].flatten), r237]; rescue => e; p [237, :raised, e.class]; end
r238 = [5]
begin; p [238, (a, b = r238; [a, b]), r238]; rescue => e; p [238, :raised, e.class]; end
r239 = [3, 1, 2, nil]
begin; p [239, (a, *b = r239; b), r239]; rescue => e; p [239, :raised, e.class]; end
r240 = [2.5, 1.5, 3.0]
begin; p [240, (r240.map(&:to_s)), r240]; rescue => e; p [240, :raised, e.class]; end
r241 = ["b", "a", "c"]
begin; p [241, (r241.sum.class), r241]; rescue => e; p [241, :raised, e.class]; end
r242 = [2.5]
r242.clear
begin; p [242, (r242.first.class), r242]; rescue => e; p [242, :raised, e.class]; end
r243 = ["b"]
r243.clear
begin; p [243, (!r243), r243]; rescue => e; p [243, :raised, e.class]; end
r244 = [5]
begin; p [244, (r244 && 1), r244]; rescue => e; p [244, :raised, e.class]; end
r245 = [3, 1, 2, nil]
begin; p [245, (case r245
in [] then :e
in [_] then :one
else :many end), r245]; rescue => e; p [245, :raised, e.class]; end
r246 = [3, 1, 2]
begin; p [246, (r246.sort.first), r246]; rescue => e; p [246, :raised, e.class]; end
r247 = [2.5, 1.5, 3.0]
begin; p [247, (r247.uniq.size), r247]; rescue => e; p [247, :raised, e.class]; end
