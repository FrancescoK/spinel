# frozen_string_literal: true
# Every Struct and Data method on members typed scalar: Integer, Float,
# nilable Integer and Float (the sentinel), String, keyword_init; one
# class per receiver, one probe per call.
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
SII = Struct.new(:a, :b)
SIF = Struct.new(:a, :b)
SFF = Struct.new(:a, :b)
SNI = Struct.new(:a, :b)
SNF = Struct.new(:a, :b)
SSI = Struct.new(:a, :b)
SKW = Struct.new(:a, :b, keyword_init: true)
DII = Data.define(:a, :b)
DIF = Data.define(:a, :b)
DNI = Data.define(:a, :b)
DNF = Data.define(:a, :b)
DSI = Data.define(:a, :b)
r0 = SIF.new(1, 2.5)
begin; p [0, (r0.a), r0]; rescue => e; p [0, :raised, e.class]; end
r1 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [1, (r1.b), r1]; rescue => e; p [1, :raised, e.class]; end
r2 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [2, (r2.a.class), r2]; rescue => e; p [2, :raised, e.class]; end
r3 = SSI.new("x", 4)
begin; p [3, (r3.b.class), r3]; rescue => e; p [3, :raised, e.class]; end
r4 = SKW.new(a: 1, b: 2.5)
begin; p [4, (r4.a.nil?), r4]; rescue => e; p [4, :raised, e.class]; end
r5 = SFF.new(1.5, -0.0)
begin; p [5, (r5.a + r5.a), r5]; rescue => e; p [5, :raised, e.class]; end
r6 = SIF.new(1, 2.5)
begin; p [6, (r6.b * 2), r6]; rescue => e; p [6, :raised, e.class]; end
r7 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [7, (r7.a.to_s), r7]; rescue => e; p [7, :raised, e.class]; end
r8 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [8, (r8.b.inspect), r8]; rescue => e; p [8, :raised, e.class]; end
r9 = SSI.new("x", 4)
begin; p [9, ([r9.a, r9.b]), r9]; rescue => e; p [9, :raised, e.class]; end
r10 = SKW.new(a: 1, b: 2.5)
begin; p [10, (r10 == r10.dup), r10]; rescue => e; p [10, :raised, e.class]; end
r11 = SFF.new(1.5, -0.0)
begin; p [11, (r11 == r11.class.new(1.5, -0.0)), r11]; rescue => e; p [11, :raised, e.class]; end
r12 = SIF.new(1, 2.5)
begin; p [12, (r12 == r12.class.new(5, 2.5)), r12]; rescue => e; p [12, :raised, e.class]; end
r13 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [13, (r13 == 1), r13]; rescue => e; p [13, :raised, e.class]; end
r14 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [14, (r14 != r14.dup), r14]; rescue => e; p [14, :raised, e.class]; end
r15 = SSI.new("x", 4)
begin; p [15, (r15.eql?(r15.dup)), r15]; rescue => e; p [15, :raised, e.class]; end
r16 = SKW.new(a: 1, b: 2.5)
begin; p [16, (r16.eql?(r16.class.new(1, 2.5))), r16]; rescue => e; p [16, :raised, e.class]; end
r17 = SFF.new(1.5, -0.0)
begin; p [17, (r17.equal?(r17)), r17]; rescue => e; p [17, :raised, e.class]; end
r18 = SIF.new(1, 2.5)
begin; p [18, (r18.hash == r18.dup.hash), r18]; rescue => e; p [18, :raised, e.class]; end
r19 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [19, (r19.deconstruct), r19]; rescue => e; p [19, :raised, e.class]; end
r20 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [20, (r20.deconstruct_keys([:a])), r20]; rescue => e; p [20, :raised, e.class]; end
r21 = SSI.new("x", 4)
begin; p [21, (r21.deconstruct_keys(nil)), r21]; rescue => e; p [21, :raised, e.class]; end
r22 = SKW.new(a: 1, b: 2.5)
begin; p [22, (r22.deconstruct_keys([:z])), r22]; rescue => e; p [22, :raised, e.class]; end
r23 = SFF.new(1.5, -0.0)
begin; p [23, (r23.inspect), r23]; rescue => e; p [23, :raised, e.class]; end
r24 = SIF.new(1, 2.5)
begin; p [24, (r24.to_s), r24]; rescue => e; p [24, :raised, e.class]; end
r25 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [25, (r25.members), r25]; rescue => e; p [25, :raised, e.class]; end
r26 = SSI.new("x", 4)
begin; p [26, (r26.to_h), r26]; rescue => e; p [26, :raised, e.class]; end
r27 = SKW.new(a: 1, b: 2.5)
begin; p [27, (r27.to_h { |k, v| [k.to_s, v] }), r27]; rescue => e; p [27, :raised, e.class]; end
r28 = SFF.new(1.5, -0.0)
begin; p [28, (case r28
in {a:, b:} then [a, b]
end), r28]; rescue => e; p [28, :raised, e.class]; end
r29 = SIF.new(1, 2.5)
begin; p [29, (case r29
in {a: Integer} then :int
in {a: Float} then :flt
else :other end), r29]; rescue => e; p [29, :raised, e.class]; end
r30 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [30, (r30.frozen?), r30]; rescue => e; p [30, :raised, e.class]; end
r31 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [31, (r31.dup), r31]; rescue => e; p [31, :raised, e.class]; end
r32 = SSI.new("x", 4)
begin; p [32, (r32.clone), r32]; rescue => e; p [32, :raised, e.class]; end
r33 = SFF.new(1.5, -0.0)
begin; p [33, (r33.class), r33]; rescue => e; p [33, :raised, e.class]; end
r34 = SFF.new(1.5, -0.0)
begin; p [34, (r34.is_a?(Struct)), r34]; rescue => e; p [34, :raised, e.class]; end
r35 = SIF.new(1, 2.5)
begin; p [35, (r35.is_a?(Data)), r35]; rescue => e; p [35, :raised, e.class]; end
r36 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [36, (r36.respond_to?(:a=)), r36]; rescue => e; p [36, :raised, e.class]; end
r37 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [37, (r37.respond_to?(:each)), r37]; rescue => e; p [37, :raised, e.class]; end
r38 = SSI.new("x", 4)
begin; p [38, (r38.itself), r38]; rescue => e; p [38, :raised, e.class]; end
r39 = SKW.new(a: 1, b: 2.5)
begin; p [39, (r39.tap { |q| q }), r39]; rescue => e; p [39, :raised, e.class]; end
r40 = SFF.new(1.5, -0.0)
begin; p [40, (r40.then { |q| q.a }), r40]; rescue => e; p [40, :raised, e.class]; end
r41 = SIF.new(1, 2.5)
begin; p [41, (r41.send(:a)), r41]; rescue => e; p [41, :raised, e.class]; end
r42 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [42, (r42.public_send(:b)), r42]; rescue => e; p [42, :raised, e.class]; end
r43 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [43, (r43.method(:a).call), r43]; rescue => e; p [43, :raised, e.class]; end
r44 = SSI.new("x", 4)
begin; p [44, (r44.instance_variables), r44]; rescue => e; p [44, :raised, e.class]; end
r45 = SKW.new(a: 1, b: 2.5)
begin; p [45, (r45.nil?), r45]; rescue => e; p [45, :raised, e.class]; end
r46 = SFF.new(1.5, -0.0)
begin; p [46, (!r46), r46]; rescue => e; p [46, :raised, e.class]; end
r47 = SIF.new(1, 2.5)
begin; p [47, ("<" + r47.inspect + ">"), r47]; rescue => e; p [47, :raised, e.class]; end
r48 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [48, ([r48].map(&:a)), r48]; rescue => e; p [48, :raised, e.class]; end
r49 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [49, ([r49, r49.dup].uniq.size), r49]; rescue => e; p [49, :raised, e.class]; end
r50 = SSI.new("x", 4)
begin; p [50, ({r50 => 1}[r50.dup]), r50]; rescue => e; p [50, :raised, e.class]; end
r51 = SKW.new(a: 1, b: 2.5)
begin; p [51, (r51.a.to_s + r51.b.to_s), r51]; rescue => e; p [51, :raised, e.class]; end
r52 = SFF.new(1.5, -0.0)
begin; p [52, (r52.a <=> 5.5), r52]; rescue => e; p [52, :raised, e.class]; end
r53 = SIF.new(1, 2.5)
begin; p [53, (r53.b.zero?), r53]; rescue => e; p [53, :raised, e.class]; end
r54 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [54, (r54.to_h.values), r54]; rescue => e; p [54, :raised, e.class]; end
r55 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [55, (r55.to_h.keys), r55]; rescue => e; p [55, :raised, e.class]; end
r56 = SIF.new(1, 2.5)
begin; p [56, (r56[0]), r56]; rescue => e; p [56, :raised, e.class]; end
r57 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [57, (r57[1]), r57]; rescue => e; p [57, :raised, e.class]; end
r58 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [58, (r58[-1]), r58]; rescue => e; p [58, :raised, e.class]; end
r59 = SKW.new(a: 1, b: 2.5)
begin; p [59, (r59[:a]), r59]; rescue => e; p [59, :raised, e.class]; end
r60 = SIF.new(1, 2.5)
begin; p [60, (r60["b"]), r60]; rescue => e; p [60, :raised, e.class]; end
r61 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [61, (r61[9]), r61]; rescue => e; p [61, :raised, e.class]; end
r62 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [62, (r62[:z]), r62]; rescue => e; p [62, :raised, e.class]; end
r63 = SKW.new(a: 1, b: 2.5)
begin; p [63, (r63[1.0]), r63]; rescue => e; p [63, :raised, e.class]; end
r64 = SIF.new(1, 2.5)
begin; p [64, (r64[0] = 5), r64]; rescue => e; p [64, :raised, e.class]; end
r65 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [65, (r65[:b] = 6), r65]; rescue => e; p [65, :raised, e.class]; end
r66 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [66, (r66["a"] = 5.5), r66]; rescue => e; p [66, :raised, e.class]; end
r67 = SKW.new(a: 1, b: 2.5)
begin; p [67, (r67[5] = 5), r67]; rescue => e; p [67, :raised, e.class]; end
r68 = SIF.new(1, 2.5)
begin; p [68, (r68.a = 5), r68]; rescue => e; p [68, :raised, e.class]; end
r69 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [69, (r69.b = 6), r69]; rescue => e; p [69, :raised, e.class]; end
r70 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [70, ((r70.a = 5.5; r70.a)), r70]; rescue => e; p [70, :raised, e.class]; end
r71 = SKW.new(a: 1, b: 2.5)
begin; p [71, (r71.dig(:a)), r71]; rescue => e; p [71, :raised, e.class]; end
r72 = SIF.new(1, 2.5)
begin; p [72, (r72.dig(0)), r72]; rescue => e; p [72, :raised, e.class]; end
r73 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [73, (r73.each { |v| v }), r73]; rescue => e; p [73, :raised, e.class]; end
r74 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [74, (r74.each.to_a), r74]; rescue => e; p [74, :raised, e.class]; end
r75 = SKW.new(a: 1, b: 2.5)
begin; p [75, (r75.each_pair { |k, v| k }), r75]; rescue => e; p [75, :raised, e.class]; end
r76 = SIF.new(1, 2.5)
begin; p [76, (r76.each_pair.to_a), r76]; rescue => e; p [76, :raised, e.class]; end
r77 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [77, (r77.filter { |v| v }), r77]; rescue => e; p [77, :raised, e.class]; end
r78 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [78, (r78.select { |v| v == 3.5 }), r78]; rescue => e; p [78, :raised, e.class]; end
r79 = SKW.new(a: 1, b: 2.5)
begin; p [79, (r79.length), r79]; rescue => e; p [79, :raised, e.class]; end
r80 = SIF.new(1, 2.5)
begin; p [80, (r80.size), r80]; rescue => e; p [80, :raised, e.class]; end
r81 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [81, (r81.to_a), r81]; rescue => e; p [81, :raised, e.class]; end
r82 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [82, (r82.values), r82]; rescue => e; p [82, :raised, e.class]; end
r83 = SKW.new(a: 1, b: 2.5)
begin; p [83, (r83.values_at(0, 1)), r83]; rescue => e; p [83, :raised, e.class]; end
r84 = SIF.new(1, 2.5)
begin; p [84, (r84.values_at(0..1)), r84]; rescue => e; p [84, :raised, e.class]; end
r85 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [85, (r85.values_at(5)), r85]; rescue => e; p [85, :raised, e.class]; end
r86 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [86, (r86.map { |v| v }), r86]; rescue => e; p [86, :raised, e.class]; end
r87 = SKW.new(a: 1, b: 2.5)
begin; p [87, (r87.sum), r87]; rescue => e; p [87, :raised, e.class]; end
r88 = SIF.new(1, 2.5)
begin; p [88, (r88.min), r88]; rescue => e; p [88, :raised, e.class]; end
r89 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [89, (r89.max), r89]; rescue => e; p [89, :raised, e.class]; end
r90 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [90, (r90.sort), r90]; rescue => e; p [90, :raised, e.class]; end
r91 = SKW.new(a: 1, b: 2.5)
begin; p [91, (r91.include?(1)), r91]; rescue => e; p [91, :raised, e.class]; end
r92 = SIF.new(1, 2.5)
begin; p [92, (r92.include?(5)), r92]; rescue => e; p [92, :raised, e.class]; end
r93 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [93, (r93.count), r93]; rescue => e; p [93, :raised, e.class]; end
r94 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [94, (r94.first), r94]; rescue => e; p [94, :raised, e.class]; end
r95 = SKW.new(a: 1, b: 2.5)
begin; p [95, (r95.entries), r95]; rescue => e; p [95, :raised, e.class]; end
r96 = SIF.new(1, 2.5)
begin; p [96, (r96.each_with_index.to_a), r96]; rescue => e; p [96, :raised, e.class]; end
r97 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [97, (r97.tally), r97]; rescue => e; p [97, :raised, e.class]; end
r98 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [98, (r98.zip([1, 2])), r98]; rescue => e; p [98, :raised, e.class]; end
r99 = SKW.new(a: 1, b: 2.5)
begin; p [99, (r99.minmax), r99]; rescue => e; p [99, :raised, e.class]; end
r100 = SIF.new(1, 2.5)
begin; p [100, (r100.find_index(2.5)), r100]; rescue => e; p [100, :raised, e.class]; end
r101 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [101, (r101.to_a.sum), r101]; rescue => e; p [101, :raised, e.class]; end
r102 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [102, (case r102
in [x, y] then [x, y]
end), r102]; rescue => e; p [102, :raised, e.class]; end
r103 = SKW.new(a: 1, b: 2.5)
begin; p [103, (a, b = *r103; [a, b]), r103]; rescue => e; p [103, :raised, e.class]; end
r104 = SIF.new(1, 2.5)
begin; p [104, (r104.freeze.a = 5), r104]; rescue => e; p [104, :raised, e.class]; end
r105 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [105, (r105.dup.tap { |q| q.a = 5 } == r105), r105]; rescue => e; p [105, :raised, e.class]; end
r106 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [106, (r106.each_slice(1).to_a), r106]; rescue => e; p [106, :raised, e.class]; end
r107 = SKW.new(a: 1, b: 2.5)
begin; p [107, (r107.inject { |x, y| x }), r107]; rescue => e; p [107, :raised, e.class]; end
r108 = SIF.new(1, 2.5)
begin; p [108, (r108.to_a.map(&:class)), r108]; rescue => e; p [108, :raised, e.class]; end
r109 = SNI.new(ARGV.size == 9 ? nil : 3, 4)
begin; p [109, (r109.a += 5 if r109.a), r109]; rescue => e; p [109, :raised, e.class]; end
r110 = SNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [110, (r110.b += 6.5), r110]; rescue => e; p [110, :raised, e.class]; end
r111 = DIF.new(1, 2.5)
begin; p [111, (r111.a), r111]; rescue => e; p [111, :raised, e.class]; end
r112 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [112, (r112.b), r112]; rescue => e; p [112, :raised, e.class]; end
r113 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [113, (r113.a.class), r113]; rescue => e; p [113, :raised, e.class]; end
r114 = DSI.new(a: "x", b: 4)
begin; p [114, (r114.b.class), r114]; rescue => e; p [114, :raised, e.class]; end
r115 = DIF.new(1, 2.5)
begin; p [115, (r115.a.nil?), r115]; rescue => e; p [115, :raised, e.class]; end
r116 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [116, (r116.a + r116.a), r116]; rescue => e; p [116, :raised, e.class]; end
r117 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [117, (r117.b * 2), r117]; rescue => e; p [117, :raised, e.class]; end
r118 = DSI.new(a: "x", b: 4)
begin; p [118, (r118.a.to_s), r118]; rescue => e; p [118, :raised, e.class]; end
r119 = DIF.new(1, 2.5)
begin; p [119, (r119.b.inspect), r119]; rescue => e; p [119, :raised, e.class]; end
r120 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [120, ([r120.a, r120.b]), r120]; rescue => e; p [120, :raised, e.class]; end
r121 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [121, (r121 == r121.dup), r121]; rescue => e; p [121, :raised, e.class]; end
r122 = DSI.new(a: "x", b: 4)
begin; p [122, (r122 == r122.class.new("x", 4)), r122]; rescue => e; p [122, :raised, e.class]; end
r123 = DIF.new(1, 2.5)
begin; p [123, (r123 == r123.class.new(5, 2.5)), r123]; rescue => e; p [123, :raised, e.class]; end
r124 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [124, (r124 == 1), r124]; rescue => e; p [124, :raised, e.class]; end
r125 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [125, (r125 != r125.dup), r125]; rescue => e; p [125, :raised, e.class]; end
r126 = DSI.new(a: "x", b: 4)
begin; p [126, (r126.eql?(r126.dup)), r126]; rescue => e; p [126, :raised, e.class]; end
r127 = DIF.new(1, 2.5)
begin; p [127, (r127.eql?(r127.class.new(1, 2.5))), r127]; rescue => e; p [127, :raised, e.class]; end
r128 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [128, (r128.equal?(r128)), r128]; rescue => e; p [128, :raised, e.class]; end
r129 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [129, (r129.hash == r129.dup.hash), r129]; rescue => e; p [129, :raised, e.class]; end
r130 = DSI.new(a: "x", b: 4)
begin; p [130, (r130.deconstruct), r130]; rescue => e; p [130, :raised, e.class]; end
r131 = DIF.new(1, 2.5)
begin; p [131, (r131.deconstruct_keys([:a])), r131]; rescue => e; p [131, :raised, e.class]; end
r132 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [132, (r132.deconstruct_keys(nil)), r132]; rescue => e; p [132, :raised, e.class]; end
r133 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [133, (r133.deconstruct_keys([:z])), r133]; rescue => e; p [133, :raised, e.class]; end
r134 = DSI.new(a: "x", b: 4)
begin; p [134, (r134.inspect), r134]; rescue => e; p [134, :raised, e.class]; end
r135 = DIF.new(1, 2.5)
begin; p [135, (r135.to_s), r135]; rescue => e; p [135, :raised, e.class]; end
r136 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [136, (r136.members), r136]; rescue => e; p [136, :raised, e.class]; end
r137 = DSI.new(a: "x", b: 4)
begin; p [137, (r137.to_h), r137]; rescue => e; p [137, :raised, e.class]; end
r138 = DIF.new(1, 2.5)
begin; p [138, (r138.to_h { |k, v| [k.to_s, v] }), r138]; rescue => e; p [138, :raised, e.class]; end
r139 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [139, (case r139
in {a:, b:} then [a, b]
end), r139]; rescue => e; p [139, :raised, e.class]; end
r140 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [140, (case r140
in {a: Integer} then :int
in {a: Float} then :flt
else :other end), r140]; rescue => e; p [140, :raised, e.class]; end
r141 = DSI.new(a: "x", b: 4)
begin; p [141, (r141.frozen?), r141]; rescue => e; p [141, :raised, e.class]; end
r142 = DIF.new(1, 2.5)
begin; p [142, (r142.dup), r142]; rescue => e; p [142, :raised, e.class]; end
r143 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [143, (r143.clone), r143]; rescue => e; p [143, :raised, e.class]; end
r144 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [144, (r144.class), r144]; rescue => e; p [144, :raised, e.class]; end
r145 = DSI.new(a: "x", b: 4)
begin; p [145, (r145.is_a?(Struct)), r145]; rescue => e; p [145, :raised, e.class]; end
r146 = DIF.new(1, 2.5)
begin; p [146, (r146.is_a?(Data)), r146]; rescue => e; p [146, :raised, e.class]; end
r147 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [147, (r147.respond_to?(:a=)), r147]; rescue => e; p [147, :raised, e.class]; end
r148 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [148, (r148.respond_to?(:each)), r148]; rescue => e; p [148, :raised, e.class]; end
r149 = DSI.new(a: "x", b: 4)
begin; p [149, (r149.itself), r149]; rescue => e; p [149, :raised, e.class]; end
r150 = DIF.new(1, 2.5)
begin; p [150, (r150.tap { |q| q }), r150]; rescue => e; p [150, :raised, e.class]; end
r151 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [151, (r151.then { |q| q.a }), r151]; rescue => e; p [151, :raised, e.class]; end
r152 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [152, (r152.send(:a)), r152]; rescue => e; p [152, :raised, e.class]; end
r153 = DSI.new(a: "x", b: 4)
begin; p [153, (r153.public_send(:b)), r153]; rescue => e; p [153, :raised, e.class]; end
r154 = DIF.new(1, 2.5)
begin; p [154, (r154.method(:a).call), r154]; rescue => e; p [154, :raised, e.class]; end
r155 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [155, (r155.instance_variables), r155]; rescue => e; p [155, :raised, e.class]; end
r156 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [156, (r156.nil?), r156]; rescue => e; p [156, :raised, e.class]; end
r157 = DSI.new(a: "x", b: 4)
begin; p [157, (!r157), r157]; rescue => e; p [157, :raised, e.class]; end
r158 = DIF.new(1, 2.5)
begin; p [158, ("<" + r158.inspect + ">"), r158]; rescue => e; p [158, :raised, e.class]; end
r159 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [159, ([r159].map(&:a)), r159]; rescue => e; p [159, :raised, e.class]; end
r160 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [160, ([r160, r160.dup].uniq.size), r160]; rescue => e; p [160, :raised, e.class]; end
r161 = DSI.new(a: "x", b: 4)
begin; p [161, ({r161 => 1}[r161.dup]), r161]; rescue => e; p [161, :raised, e.class]; end
r162 = DIF.new(1, 2.5)
begin; p [162, (r162.a.to_s + r162.b.to_s), r162]; rescue => e; p [162, :raised, e.class]; end
r163 = DNI.new(a: ARGV.size == 9 ? nil : 3, b: 4)
begin; p [163, (r163.a <=> 5), r163]; rescue => e; p [163, :raised, e.class]; end
r164 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [164, (r164.b.zero?), r164]; rescue => e; p [164, :raised, e.class]; end
r165 = DSI.new(a: "x", b: 4)
begin; p [165, (r165.to_h.values), r165]; rescue => e; p [165, :raised, e.class]; end
r166 = DIF.new(1, 2.5)
begin; p [166, (r166.to_h.keys), r166]; rescue => e; p [166, :raised, e.class]; end
r167 = DIF.new(1, 2.5)
begin; p [167, (r167.with(a: 5)), r167]; rescue => e; p [167, :raised, e.class]; end
r168 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [168, (r168.with(b: 6.5).b), r168]; rescue => e; p [168, :raised, e.class]; end
r169 = DIF.new(1, 2.5)
begin; p [169, (r169.with), r169]; rescue => e; p [169, :raised, e.class]; end
r170 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [170, (r170.with(z: 1)), r170]; rescue => e; p [170, :raised, e.class]; end
r171 = DIF.new(1, 2.5)
begin; p [171, (r171.with(a: 5) == r171), r171]; rescue => e; p [171, :raised, e.class]; end
r172 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [172, (r172.with(a: 3.5) == r172), r172]; rescue => e; p [172, :raised, e.class]; end
r173 = DIF.new(1, 2.5)
begin; p [173, (r173.with(a: 5).a.class), r173]; rescue => e; p [173, :raised, e.class]; end
r174 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [174, (r174.class.new(a: 5.5, b: 6.5).to_h), r174]; rescue => e; p [174, :raised, e.class]; end
r175 = DIF.new(1, 2.5)
begin; p [175, (r175.class.new(5)), r175]; rescue => e; p [175, :raised, e.class]; end
r176 = DNF.new(ARGV.size == 9 ? nil : 3.5, 4.5)
begin; p [176, (r176.class.new(a: 3.5, b: 4.5, c: 1)), r176]; rescue => e; p [176, :raised, e.class]; end
r177 = DIF.new(1, 2.5)
begin; p [177, (r177.class.new(**r177.to_h)), r177]; rescue => e; p [177, :raised, e.class]; end
r178 = DIF.new(1, 2.5)
begin; p [178, (r178.instance_variable_get(:@a)), r178]; rescue => e; p [178, :raised, e.class]; end
