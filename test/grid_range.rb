# frozen_string_literal: true
# Every Range method on the by-value range structs: sp_Range (finite,
# empty, endless, beginless), sp_FloatRange and sp_StrRange, one probe
# per call, the receivers taken in turn.
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
r0 = (1..5)
begin; p [0, (r0.begin)]; rescue => e; p [0, :raised, e.class]; end
r1 = (..5)
begin; p [1, (r1.end)]; rescue => e; p [1, :raised, e.class]; end
r2 = (1..)
begin; p [2, (r2.first)]; rescue => e; p [2, :raised, e.class]; end
r3 = (1.0..2.5)
begin; p [3, (r3.first(2))]; rescue => e; p [3, :raised, e.class]; end
r4 = (1.0..)
begin; p [4, (r4.first(0))]; rescue => e; p [4, :raised, e.class]; end
r5 = ("a".."e")
begin; p [5, (r5.last)]; rescue => e; p [5, :raised, e.class]; end
r6 = ("a"..)
begin; p [6, (r6.last(2))]; rescue => e; p [6, :raised, e.class]; end
r7 = (5..1)
begin; p [7, (r7.min)]; rescue => e; p [7, :raised, e.class]; end
r8 = (..2.5)
begin; p [8, (r8.max)]; rescue => e; p [8, :raised, e.class]; end
r9 = (1..5)
begin; p [9, (r9.minmax)]; rescue => e; p [9, :raised, e.class]; end
r10 = (1..)
begin; p [10, (r10.min { |a, b| b <=> a })]; rescue => e; p [10, :raised, e.class]; end
r11 = (1..)
begin; p [11, (r11.max(2))]; rescue => e; p [11, :raised, e.class]; end
r12 = (1.0..2.5)
begin; p [12, (r12.min_by { |x| x })]; rescue => e; p [12, :raised, e.class]; end
r13 = (1.0..)
begin; p [13, (r13.sum)]; rescue => e; p [13, :raised, e.class]; end
r14 = ("a".."e")
begin; p [14, (r14.size)]; rescue => e; p [14, :raised, e.class]; end
r15 = (5..1)
begin; p [15, (r15.count)]; rescue => e; p [15, :raised, e.class]; end
r16 = (5..1)
begin; p [16, (r16.count(3))]; rescue => e; p [16, :raised, e.class]; end
r17 = (..2.5)
begin; p [17, (r17.count { |x| x == 1.5 })]; rescue => e; p [17, :raised, e.class]; end
r18 = (1..5)
begin; p [18, (r18.to_a)]; rescue => e; p [18, :raised, e.class]; end
r19 = (..5)
begin; p [19, (r19.entries)]; rescue => e; p [19, :raised, e.class]; end
r20 = (1..)
begin; p [20, (r20.to_set.size)]; rescue => e; p [20, :raised, e.class]; end
r21 = (1.0..2.5)
begin; p [21, (r21.each { |x| x })]; rescue => e; p [21, :raised, e.class]; end
r22 = (1.0..)
begin; p [22, (r22.each.first(2))]; rescue => e; p [22, :raised, e.class]; end
r23 = ("a".."e")
begin; p [23, (r23.reverse_each.first(2))]; rescue => e; p [23, :raised, e.class]; end
r24 = (5..1)
begin; p [24, (r24.reverse_each { |x| break x })]; rescue => e; p [24, :raised, e.class]; end
r25 = (5..1)
begin; p [25, (r25.step(2).to_a)]; rescue => e; p [25, :raised, e.class]; end
r26 = (1..5)
begin; p [26, (r26.step(2).first(3))]; rescue => e; p [26, :raised, e.class]; end
r27 = (1..5)
begin; p [27, (r27.step(2) { |x| x })]; rescue => e; p [27, :raised, e.class]; end
r28 = (1..)
begin; p [28, ((r28 % 2).first(3))]; rescue => e; p [28, :raised, e.class]; end
r29 = (1..)
begin; p [29, (r29.step(0))]; rescue => e; p [29, :raised, e.class]; end
r30 = (1.0..2.5)
begin; p [30, (r30.step(-1).to_a)]; rescue => e; p [30, :raised, e.class]; end
r31 = (1.0..)
begin; p [31, (r31.include?(1.5))]; rescue => e; p [31, :raised, e.class]; end
r32 = ("a".."e")
begin; p [32, (r32.include?("z"))]; rescue => e; p [32, :raised, e.class]; end
r33 = ("a"..)
begin; p [33, (r33.member?("c"))]; rescue => e; p [33, :raised, e.class]; end
r34 = (5..1)
begin; p [34, (r34.cover?(3))]; rescue => e; p [34, :raised, e.class]; end
r35 = (..2.5)
begin; p [35, (r35.cover?(9.0))]; rescue => e; p [35, :raised, e.class]; end
r36 = (1..5)
begin; p [36, (r36.cover?(r36))]; rescue => e; p [36, :raised, e.class]; end
r37 = (..5)
begin; p [37, (r37.cover?(nil))]; rescue => e; p [37, :raised, e.class]; end
r38 = (1..)
begin; p [38, (r38 === 3)]; rescue => e; p [38, :raised, e.class]; end
r39 = (1.0..2.5)
begin; p [39, (r39 === 9.0)]; rescue => e; p [39, :raised, e.class]; end
r40 = (1.0..)
begin; p [40, (r40 === nil)]; rescue => e; p [40, :raised, e.class]; end
r41 = ("a".."e")
begin; p [41, (r41 === "x")]; rescue => e; p [41, :raised, e.class]; end
r42 = ("a"..)
begin; p [42, (r42 === 1.5)]; rescue => e; p [42, :raised, e.class]; end
r43 = (5..1)
begin; p [43, (r43.include?(1.5))]; rescue => e; p [43, :raised, e.class]; end
r44 = (..2.5)
begin; p [44, (r44.include?("c"))]; rescue => e; p [44, :raised, e.class]; end
r45 = (1..5)
begin; p [45, (r45 == r45.dup)]; rescue => e; p [45, :raised, e.class]; end
r46 = (..5)
begin; p [46, (r46 == (1..5))]; rescue => e; p [46, :raised, e.class]; end
r47 = (1..)
begin; p [47, (r47.eql?(r47.dup))]; rescue => e; p [47, :raised, e.class]; end
r48 = (1.0..2.5)
begin; p [48, (r48.eql?(1..5))]; rescue => e; p [48, :raised, e.class]; end
r49 = (1.0..)
begin; p [49, (r49.hash == r49.dup.hash)]; rescue => e; p [49, :raised, e.class]; end
r50 = ("a".."e")
begin; p [50, (r50.exclude_end?)]; rescue => e; p [50, :raised, e.class]; end
r51 = ("a"..)
begin; p [51, (r51.inspect)]; rescue => e; p [51, :raised, e.class]; end
r52 = (5..1)
begin; p [52, (r52.to_s)]; rescue => e; p [52, :raised, e.class]; end
r53 = (..2.5)
begin; p [53, (r53.overlap?(r53))]; rescue => e; p [53, :raised, e.class]; end
r54 = (1..5)
begin; p [54, (r54.overlap?(100..200))]; rescue => e; p [54, :raised, e.class]; end
r55 = (..5)
begin; p [55, (r55.bsearch { |x| x >= 3 })]; rescue => e; p [55, :raised, e.class]; end
r56 = (1.0..2.5)
begin; p [56, (r56.map { |x| x })]; rescue => e; p [56, :raised, e.class]; end
r57 = (1.0..2.5)
begin; p [57, (r57.select { |x| x == 1.5 })]; rescue => e; p [57, :raised, e.class]; end
r58 = (1.0..)
begin; p [58, (r58.reject { |x| x == 1.5 })]; rescue => e; p [58, :raised, e.class]; end
r59 = ("a".."e")
begin; p [59, (r59.filter_map { |x| x if x == "c" })]; rescue => e; p [59, :raised, e.class]; end
r60 = (5..1)
begin; p [60, (r60.each_slice(2).to_a)]; rescue => e; p [60, :raised, e.class]; end
r61 = (5..1)
begin; p [61, (r61.each_cons(2).first(2))]; rescue => e; p [61, :raised, e.class]; end
r62 = (..2.5)
begin; p [62, (r62.each_with_index.first(2))]; rescue => e; p [62, :raised, e.class]; end
r63 = (1..5)
begin; p [63, (r63.each_with_object([]) { |x, a| a << x })]; rescue => e; p [63, :raised, e.class]; end
r64 = (1.0..2.5)
begin; p [64, (r64.inject { |a, b| b })]; rescue => e; p [64, :raised, e.class]; end
r65 = (1.0..2.5)
begin; p [65, (r65.reduce(:+))]; rescue => e; p [65, :raised, e.class]; end
r66 = (1.0..2.5)
begin; p [66, (r66.find { |x| x == 1.5 })]; rescue => e; p [66, :raised, e.class]; end
r67 = (1.0..)
begin; p [67, (r67.find_index(1.5))]; rescue => e; p [67, :raised, e.class]; end
r68 = ("a".."e")
begin; p [68, (r68.find_index { |x| x == "c" })]; rescue => e; p [68, :raised, e.class]; end
r69 = ("a"..)
begin; p [69, (r69.take(2))]; rescue => e; p [69, :raised, e.class]; end
r70 = (5..1)
begin; p [70, (r70.drop(1))]; rescue => e; p [70, :raised, e.class]; end
r71 = (..2.5)
begin; p [71, (r71.take_while { |x| x != 1.5 })]; rescue => e; p [71, :raised, e.class]; end
r72 = (1..5)
begin; p [72, (r72.drop_while { |x| x != 3 })]; rescue => e; p [72, :raised, e.class]; end
r73 = (..5)
begin; p [73, (r73.sort)]; rescue => e; p [73, :raised, e.class]; end
r74 = (1.0..2.5)
begin; p [74, (r74.sort_by { |x| x })]; rescue => e; p [74, :raised, e.class]; end
r75 = (1.0..2.5)
begin; p [75, (r75.tally)]; rescue => e; p [75, :raised, e.class]; end
r76 = (1.0..)
begin; p [76, (r76.zip(r76))]; rescue => e; p [76, :raised, e.class]; end
r77 = ("a".."e")
begin; p [77, (r77.group_by { |x| x })]; rescue => e; p [77, :raised, e.class]; end
r78 = (5..1)
begin; p [78, (r78.partition { |x| x == 3 })]; rescue => e; p [78, :raised, e.class]; end
r79 = (5..1)
begin; p [79, (r79.each_entry.first(2))]; rescue => e; p [79, :raised, e.class]; end
r80 = (..2.5)
begin; p [80, (r80.lazy.map { |x| x }.first(2))]; rescue => e; p [80, :raised, e.class]; end
r81 = (1..5)
begin; p [81, (r81.chunk_while { |a, b| true }.to_a)]; rescue => e; p [81, :raised, e.class]; end
r82 = (..5)
begin; p [82, (r82.minmax_by { |x| x })]; rescue => e; p [82, :raised, e.class]; end
r83 = (1.0..2.5)
begin; p [83, (r83.uniq)]; rescue => e; p [83, :raised, e.class]; end
r84 = (1.0..2.5)
begin; p [84, (r84.include?(nil))]; rescue => e; p [84, :raised, e.class]; end
r85 = (1.0..)
begin; p [85, (r85.any?)]; rescue => e; p [85, :raised, e.class]; end
r86 = ("a".."e")
begin; p [86, (r86.all? { |x| x })]; rescue => e; p [86, :raised, e.class]; end
r87 = (5..1)
begin; p [87, (r87.none?)]; rescue => e; p [87, :raised, e.class]; end
r88 = (5..1)
begin; p [88, (r88.to_a.size)]; rescue => e; p [88, :raised, e.class]; end
r89 = (..2.5)
begin; p [89, (r89.first.class)]; rescue => e; p [89, :raised, e.class]; end
r90 = (1..5)
begin; p [90, (r90.last.class)]; rescue => e; p [90, :raised, e.class]; end
r91 = (..5)
begin; p [91, (r91.min.class)]; rescue => e; p [91, :raised, e.class]; end
r92 = (1..)
begin; p [92, (r92.begin.class)]; rescue => e; p [92, :raised, e.class]; end
r93 = (1.0..2.5)
begin; p [93, (r93.end.class)]; rescue => e; p [93, :raised, e.class]; end
r94 = (1.0..)
begin; p [94, (r94.frozen?)]; rescue => e; p [94, :raised, e.class]; end
r95 = ("a".."e")
begin; p [95, (r95.dup)]; rescue => e; p [95, :raised, e.class]; end
r96 = ("a"..)
begin; p [96, (r96.clone)]; rescue => e; p [96, :raised, e.class]; end
r97 = (5..1)
begin; p [97, (r97.class)]; rescue => e; p [97, :raised, e.class]; end
r98 = (..2.5)
begin; p [98, (r98.is_a?(Range))]; rescue => e; p [98, :raised, e.class]; end
r99 = (1..5)
begin; p [99, (r99.is_a?(Enumerable))]; rescue => e; p [99, :raised, e.class]; end
r100 = (..5)
begin; p [100, (r100.respond_to?(:each))]; rescue => e; p [100, :raised, e.class]; end
r101 = (1..)
begin; p [101, (r101.itself)]; rescue => e; p [101, :raised, e.class]; end
r102 = (5..1)
begin; p [102, (r102.tap { |q| q })]; rescue => e; p [102, :raised, e.class]; end
r103 = ("a".."e")
begin; p [103, (r103.then { |q| q.begin })]; rescue => e; p [103, :raised, e.class]; end
r104 = ("a".."e")
begin; p [104, (r104.send(:begin))]; rescue => e; p [104, :raised, e.class]; end
r105 = (5..1)
begin; p [105, (r105.instance_variables)]; rescue => e; p [105, :raised, e.class]; end
r106 = (..2.5)
begin; p [106, (r106 =~ /a/)]; rescue => e; p [106, :raised, e.class]; end
r107 = (1..5)
begin; p [107, (!r107)]; rescue => e; p [107, :raised, e.class]; end
r108 = ("a".."e")
begin; p [108, ([*r108])]; rescue => e; p [108, :raised, e.class]; end
r109 = (1..)
begin; p [109, (Array(r109))]; rescue => e; p [109, :raised, e.class]; end
r110 = ("a".."e")
begin; p [110, (r110.step(2).class)]; rescue => e; p [110, :raised, e.class]; end
r111 = (1.0..)
begin; p [111, (case 1.5 when r111 then :in else :out end)]; rescue => e; p [111, :raised, e.class]; end
r112 = ("a".."e")
begin; p [112, (case "z" when r112 then :in else :out end)]; rescue => e; p [112, :raised, e.class]; end
r113 = ("a"..)
begin; p [113, (r113.to_a.reverse)]; rescue => e; p [113, :raised, e.class]; end
r114 = (5..1)
begin; p [114, (r114.sum { |x| 1 })]; rescue => e; p [114, :raised, e.class]; end
r115 = (..2.5)
begin; p [115, (r115.each_slice(2).map(&:size))]; rescue => e; p [115, :raised, e.class]; end
r116 = (1..5)
begin; p [116, (r116.count.class)]; rescue => e; p [116, :raised, e.class]; end
r117 = (..5)
begin; p [117, (r117.size.class)]; rescue => e; p [117, :raised, e.class]; end
r118 = (1..)
begin; p [118, (a, b = r118.minmax; [a, b])]; rescue => e; p [118, :raised, e.class]; end
r119 = (1.0..2.5)
begin; p [119, (1.5.clamp(r119))]; rescue => e; p [119, :raised, e.class]; end
r120 = (1.0..)
begin; p [120, (-9.0.clamp(r120))]; rescue => e; p [120, :raised, e.class]; end
r121 = ("a".."e")
begin; p [121, ("c".between?(r121.begin || "c", r121.end || "c"))]; rescue => e; p [121, :raised, e.class]; end
r122 = ("a"..)
begin; p [122, (r122.first(1).class)]; rescue => e; p [122, :raised, e.class]; end
r123 = (5..1)
begin; p [123, (r123.max { |a, b| a <=> b })]; rescue => e; p [123, :raised, e.class]; end
