# spinel: int64
# frozen_string_literal: true
# Every Float method on the unboxed representations, edge values first: a
# plain double (-0.0, NaN, Infinity, -3.75, 1e20, 2.5) and the nilable
# sentinel (a local, and straight from a method), one probe per call.
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
def mf(k) = k == 0 ? nil : 2.5
def mg(k) = k == 0 ? nil : -0.5
r0 = -0.0 * (ARGV.size + 1)
begin; p [0, (r0 % 2)]; rescue => e; p [0, :raised, e.class]; end
r1 = Float::NAN + ARGV.size
begin; p [1, (r1 % -2)]; rescue => e; p [1, :raised, e.class]; end
r2 = Float::INFINITY - ARGV.size
begin; p [2, (r2 % 0)]; rescue => e; p [2, :raised, e.class]; end
r3 = ARGV.size - 3.75
begin; p [3, (r3 % 0.0)]; rescue => e; p [3, :raised, e.class]; end
begin; p [4, (mf(1) % 1.5)]; rescue => e; p [4, :raised, e.class]; end
r5 = ARGV.size == 9 ? nil : -0.5
begin; p [5, (r5 * 3)]; rescue => e; p [5, :raised, e.class]; end
r6 = 1e20 + ARGV.size
begin; p [6, (r6 * 2.5)]; rescue => e; p [6, :raised, e.class]; end
r7 = 2.5
begin; p [7, (r7 * 0)]; rescue => e; p [7, :raised, e.class]; end
r8 = -0.0 * (ARGV.size + 1)
begin; p [8, (r8 * nil)]; rescue => e; p [8, :raised, e.class]; end
r9 = Float::NAN + ARGV.size
begin; p [9, (r9 * (2**70))]; rescue => e; p [9, :raised, e.class]; end
r10 = Float::INFINITY - ARGV.size
begin; p [10, (r10 ** 2)]; rescue => e; p [10, :raised, e.class]; end
r11 = ARGV.size - 3.75
begin; p [11, (r11 ** -1)]; rescue => e; p [11, :raised, e.class]; end
begin; p [12, (mf(1) ** 0.5)]; rescue => e; p [12, :raised, e.class]; end
r13 = ARGV.size == 9 ? nil : -0.5
begin; p [13, (r13 ** 0)]; rescue => e; p [13, :raised, e.class]; end
r14 = 1e20 + ARGV.size
begin; p [14, (r14 ** 400)]; rescue => e; p [14, :raised, e.class]; end
r15 = 2.5
begin; p [15, (r15 + 1)]; rescue => e; p [15, :raised, e.class]; end
r16 = -0.0 * (ARGV.size + 1)
begin; p [16, (r16 + 1.5)]; rescue => e; p [16, :raised, e.class]; end
r17 = Float::NAN + ARGV.size
begin; p [17, (r17 + nil)]; rescue => e; p [17, :raised, e.class]; end
r18 = Float::INFINITY - ARGV.size
begin; p [18, (r18 + "a")]; rescue => e; p [18, :raised, e.class]; end
r19 = ARGV.size - 3.75
begin; p [19, (r19 + (2**70))]; rescue => e; p [19, :raised, e.class]; end
begin; p [20, (mf(1) + 1r)]; rescue => e; p [20, :raised, e.class]; end
r21 = ARGV.size == 9 ? nil : -0.5
begin; p [21, (r21 - 1)]; rescue => e; p [21, :raised, e.class]; end
r22 = 1e20 + ARGV.size
begin; p [22, (r22 - 2.5)]; rescue => e; p [22, :raised, e.class]; end
r23 = 2.5
begin; p [23, (-r23)]; rescue => e; p [23, :raised, e.class]; end
r24 = -0.0 * (ARGV.size + 1)
begin; p [24, (+r24)]; rescue => e; p [24, :raised, e.class]; end
r25 = Float::NAN + ARGV.size
begin; p [25, (r25 / 2)]; rescue => e; p [25, :raised, e.class]; end
r26 = Float::INFINITY - ARGV.size
begin; p [26, (r26 / 0)]; rescue => e; p [26, :raised, e.class]; end
r27 = ARGV.size - 3.75
begin; p [27, (r27 / 0.0)]; rescue => e; p [27, :raised, e.class]; end
begin; p [28, (mf(1) / -0.0)]; rescue => e; p [28, :raised, e.class]; end
r29 = ARGV.size == 9 ? nil : -0.5
begin; p [29, (r29 / 2r)]; rescue => e; p [29, :raised, e.class]; end
r30 = 1e20 + ARGV.size
begin; p [30, (r30 < 5)]; rescue => e; p [30, :raised, e.class]; end
r31 = 2.5
begin; p [31, (r31 < 5.5)]; rescue => e; p [31, :raised, e.class]; end
r32 = -0.0 * (ARGV.size + 1)
begin; p [32, (r32 < "a")]; rescue => e; p [32, :raised, e.class]; end
r33 = Float::NAN + ARGV.size
begin; p [33, (r33 < nil)]; rescue => e; p [33, :raised, e.class]; end
r34 = Float::INFINITY - ARGV.size
begin; p [34, (r34 <= 2.5)]; rescue => e; p [34, :raised, e.class]; end
r35 = ARGV.size - 3.75
begin; p [35, (r35 > 1)]; rescue => e; p [35, :raised, e.class]; end
begin; p [36, (mf(1) >= 2.5)]; rescue => e; p [36, :raised, e.class]; end
r37 = ARGV.size == 9 ? nil : -0.5
begin; p [37, (r37 > (2**70))]; rescue => e; p [37, :raised, e.class]; end
r38 = 1e20 + ARGV.size
begin; p [38, (r38 <=> 3)]; rescue => e; p [38, :raised, e.class]; end
r39 = 2.5
begin; p [39, (r39 <=> 2.5)]; rescue => e; p [39, :raised, e.class]; end
r40 = -0.0 * (ARGV.size + 1)
begin; p [40, (r40 <=> "a")]; rescue => e; p [40, :raised, e.class]; end
r41 = Float::NAN + ARGV.size
begin; p [41, (r41 <=> nil)]; rescue => e; p [41, :raised, e.class]; end
r42 = Float::INFINITY - ARGV.size
begin; p [42, (r42 <=> Float::NAN)]; rescue => e; p [42, :raised, e.class]; end
r43 = ARGV.size - 3.75
begin; p [43, (r43 <=> (2**70))]; rescue => e; p [43, :raised, e.class]; end
begin; p [44, (mf(1) == 2.5)]; rescue => e; p [44, :raised, e.class]; end
r45 = ARGV.size == 9 ? nil : -0.5
begin; p [45, (r45 == 7)]; rescue => e; p [45, :raised, e.class]; end
r46 = 1e20 + ARGV.size
begin; p [46, (r46 == "2.5")]; rescue => e; p [46, :raised, e.class]; end
r47 = 2.5
begin; p [47, (r47 == nil)]; rescue => e; p [47, :raised, e.class]; end
r48 = -0.0 * (ARGV.size + 1)
begin; p [48, (r48 != 2.5)]; rescue => e; p [48, :raised, e.class]; end
r49 = Float::NAN + ARGV.size
begin; p [49, (r49 == r49)]; rescue => e; p [49, :raised, e.class]; end
r50 = Float::INFINITY - ARGV.size
begin; p [50, (r50 === 2.5)]; rescue => e; p [50, :raised, e.class]; end
r51 = ARGV.size - 3.75
begin; p [51, (Float === r51)]; rescue => e; p [51, :raised, e.class]; end
begin; p [52, ((0.0..5.0) === mf(1))]; rescue => e; p [52, :raised, e.class]; end
r53 = ARGV.size == 9 ? nil : -0.5
begin; p [53, (r53.abs)]; rescue => e; p [53, :raised, e.class]; end
r54 = 1e20 + ARGV.size
begin; p [54, (r54.magnitude)]; rescue => e; p [54, :raised, e.class]; end
r55 = 2.5
begin; p [55, (r55.angle)]; rescue => e; p [55, :raised, e.class]; end
r56 = Float::INFINITY - ARGV.size
begin; p [56, (r56.arg)]; rescue => e; p [56, :raised, e.class]; end
r57 = Float::INFINITY - ARGV.size
begin; p [57, (r57.phase)]; rescue => e; p [57, :raised, e.class]; end
r58 = Float::INFINITY - ARGV.size
begin; p [58, (r58.ceil)]; rescue => e; p [58, :raised, e.class]; end
r59 = ARGV.size - 3.75
begin; p [59, (r59.ceil(1))]; rescue => e; p [59, :raised, e.class]; end
begin; p [60, (mf(1).ceil(-1))]; rescue => e; p [60, :raised, e.class]; end
r61 = ARGV.size == 9 ? nil : -0.5
begin; p [61, (r61.floor)]; rescue => e; p [61, :raised, e.class]; end
r62 = 1e20 + ARGV.size
begin; p [62, (r62.floor(1))]; rescue => e; p [62, :raised, e.class]; end
r63 = 2.5
begin; p [63, (r63.floor(-1))]; rescue => e; p [63, :raised, e.class]; end
r64 = -0.0 * (ARGV.size + 1)
begin; p [64, (r64.round)]; rescue => e; p [64, :raised, e.class]; end
r65 = Float::NAN + ARGV.size
begin; p [65, (r65.round(1))]; rescue => e; p [65, :raised, e.class]; end
r66 = Float::INFINITY - ARGV.size
begin; p [66, (r66.round(-1))]; rescue => e; p [66, :raised, e.class]; end
r67 = ARGV.size - 3.75
begin; p [67, (r67.round(half: :even))]; rescue => e; p [67, :raised, e.class]; end
begin; p [68, (mf(1).round(half: :down))]; rescue => e; p [68, :raised, e.class]; end
r69 = ARGV.size == 9 ? nil : -0.5
begin; p [69, (r69.round(half: :up))]; rescue => e; p [69, :raised, e.class]; end
r70 = 1e20 + ARGV.size
begin; p [70, (r70.round(1, half: :even))]; rescue => e; p [70, :raised, e.class]; end
r71 = 2.5
begin; p [71, (r71.truncate)]; rescue => e; p [71, :raised, e.class]; end
r72 = -0.0 * (ARGV.size + 1)
begin; p [72, (r72.truncate(1))]; rescue => e; p [72, :raised, e.class]; end
r73 = Float::NAN + ARGV.size
begin; p [73, (r73.to_i)]; rescue => e; p [73, :raised, e.class]; end
r74 = Float::INFINITY - ARGV.size
begin; p [74, (r74.to_int)]; rescue => e; p [74, :raised, e.class]; end
r75 = ARGV.size - 3.75
begin; p [75, (r75.coerce(2))]; rescue => e; p [75, :raised, e.class]; end
begin; p [76, (mf(1).coerce(2.5))]; rescue => e; p [76, :raised, e.class]; end
r77 = ARGV.size == 9 ? nil : -0.5
begin; p [77, (r77.coerce("1"))]; rescue => e; p [77, :raised, e.class]; end
r78 = 2.5
begin; p [78, (r78.denominator)]; rescue => e; p [78, :raised, e.class]; end
r79 = 2.5
begin; p [79, (r79.numerator)]; rescue => e; p [79, :raised, e.class]; end
r80 = -0.0 * (ARGV.size + 1)
begin; p [80, (r80.divmod(2))]; rescue => e; p [80, :raised, e.class]; end
r81 = Float::NAN + ARGV.size
begin; p [81, (r81.divmod(-2))]; rescue => e; p [81, :raised, e.class]; end
r82 = ARGV.size - 3.75
begin; p [82, (r82.divmod(0))]; rescue => e; p [82, :raised, e.class]; end
r83 = ARGV.size - 3.75
begin; p [83, (r83.divmod(0.5))]; rescue => e; p [83, :raised, e.class]; end
begin; p [84, (mf(1).div(2))]; rescue => e; p [84, :raised, e.class]; end
r85 = ARGV.size == 9 ? nil : -0.5
begin; p [85, (r85.div(0.5))]; rescue => e; p [85, :raised, e.class]; end
r86 = 1e20 + ARGV.size
begin; p [86, (r86.modulo(2))]; rescue => e; p [86, :raised, e.class]; end
r87 = 2.5
begin; p [87, (r87.remainder(2))]; rescue => e; p [87, :raised, e.class]; end
r88 = Float::NAN + ARGV.size
begin; p [88, (r88.eql?(2.5))]; rescue => e; p [88, :raised, e.class]; end
r89 = Float::INFINITY - ARGV.size
begin; p [89, (r89.eql?(2))]; rescue => e; p [89, :raised, e.class]; end
r90 = ARGV.size - 3.75
begin; p [90, (r90.equal?(2.5))]; rescue => e; p [90, :raised, e.class]; end
begin; p [91, (mf(1).fdiv(2))]; rescue => e; p [91, :raised, e.class]; end
r92 = ARGV.size == 9 ? nil : -0.5
begin; p [92, (r92.fdiv(0))]; rescue => e; p [92, :raised, e.class]; end
r93 = 1e20 + ARGV.size
begin; p [93, (r93.quo(2))]; rescue => e; p [93, :raised, e.class]; end
r94 = 2.5
begin; p [94, (r94.quo(0))]; rescue => e; p [94, :raised, e.class]; end
r95 = -0.0 * (ARGV.size + 1)
begin; p [95, (r95.finite?)]; rescue => e; p [95, :raised, e.class]; end
r96 = Float::NAN + ARGV.size
begin; p [96, (r96.infinite?)]; rescue => e; p [96, :raised, e.class]; end
r97 = Float::INFINITY - ARGV.size
begin; p [97, (r97.nan?)]; rescue => e; p [97, :raised, e.class]; end
r98 = ARGV.size - 3.75
begin; p [98, (r98.zero?)]; rescue => e; p [98, :raised, e.class]; end
begin; p [99, (mf(1).nonzero?)]; rescue => e; p [99, :raised, e.class]; end
r100 = ARGV.size == 9 ? nil : -0.5
begin; p [100, (r100.positive?)]; rescue => e; p [100, :raised, e.class]; end
r101 = 1e20 + ARGV.size
begin; p [101, (r101.negative?)]; rescue => e; p [101, :raised, e.class]; end
r102 = 2.5
begin; p [102, (r102.integer?)]; rescue => e; p [102, :raised, e.class]; end
r103 = -0.0 * (ARGV.size + 1)
begin; p [103, (r103.hash == (r103 + 0.0).hash)]; rescue => e; p [103, :raised, e.class]; end
r104 = Float::NAN + ARGV.size
begin; p [104, (r104.inspect)]; rescue => e; p [104, :raised, e.class]; end
r105 = Float::INFINITY - ARGV.size
begin; p [105, (r105.to_s)]; rescue => e; p [105, :raised, e.class]; end
r106 = ARGV.size - 3.75
begin; p [106, (r106.to_f)]; rescue => e; p [106, :raised, e.class]; end
begin; p [107, (mf(1).next_float)]; rescue => e; p [107, :raised, e.class]; end
r108 = ARGV.size == 9 ? nil : -0.5
begin; p [108, (r108.prev_float)]; rescue => e; p [108, :raised, e.class]; end
r109 = 2.5
begin; p [109, (r109.rationalize)]; rescue => e; p [109, :raised, e.class]; end
r110 = 2.5
begin; p [110, (r110.rationalize(0.01))]; rescue => e; p [110, :raised, e.class]; end
r111 = -0.0 * (ARGV.size + 1)
begin; p [111, (r111.to_r)]; rescue => e; p [111, :raised, e.class]; end
r112 = Float::NAN + ARGV.size
begin; p [112, (r112.to_c)]; rescue => e; p [112, :raised, e.class]; end
r113 = Float::INFINITY - ARGV.size
begin; p [113, (r113.abs2)]; rescue => e; p [113, :raised, e.class]; end
r114 = ARGV.size - 3.75
begin; p [114, (r114.conj)]; rescue => e; p [114, :raised, e.class]; end
begin; p [115, (mf(1).real)]; rescue => e; p [115, :raised, e.class]; end
r116 = ARGV.size == 9 ? nil : -0.5
begin; p [116, (r116.imag)]; rescue => e; p [116, :raised, e.class]; end
r117 = 1e20 + ARGV.size
begin; p [117, (r117.real?)]; rescue => e; p [117, :raised, e.class]; end
r118 = 2.5
begin; p [118, (r118.rect)]; rescue => e; p [118, :raised, e.class]; end
r119 = Float::INFINITY - ARGV.size
begin; p [119, (r119.polar)]; rescue => e; p [119, :raised, e.class]; end
r120 = Float::NAN + ARGV.size
begin; p [120, (r120.i)]; rescue => e; p [120, :raised, e.class]; end
r121 = Float::INFINITY - ARGV.size
begin; p [121, (r121.step(10, 2.5).to_a)]; rescue => e; p [121, :raised, e.class]; end
r122 = ARGV.size - 3.75
begin; p [122, (r122.step(10, 2) { |i| i })]; rescue => e; p [122, :raised, e.class]; end
begin; p [123, (mf(1).step(by: 0.5, to: 4).to_a)]; rescue => e; p [123, :raised, e.class]; end
r124 = ARGV.size == 9 ? nil : -0.5
begin; p [124, (r124.clone)]; rescue => e; p [124, :raised, e.class]; end
r125 = 1e20 + ARGV.size
begin; p [125, (r125.dup)]; rescue => e; p [125, :raised, e.class]; end
r126 = 2.5
begin; p [126, (r126.freeze)]; rescue => e; p [126, :raised, e.class]; end
r127 = -0.0 * (ARGV.size + 1)
begin; p [127, (r127.frozen?)]; rescue => e; p [127, :raised, e.class]; end
r128 = Float::NAN + ARGV.size
begin; p [128, (r128.between?(1, 10))]; rescue => e; p [128, :raised, e.class]; end
r129 = Float::INFINITY - ARGV.size
begin; p [129, (r129.clamp(1, 2))]; rescue => e; p [129, :raised, e.class]; end
r130 = ARGV.size - 3.75
begin; p [130, (r130.clamp(..1.5))]; rescue => e; p [130, :raised, e.class]; end
begin; p [131, (mf(1).clamp(3.5, 9))]; rescue => e; p [131, :raised, e.class]; end
r132 = ARGV.size == 9 ? nil : -0.5
begin; p [132, (r132.class)]; rescue => e; p [132, :raised, e.class]; end
r133 = 1e20 + ARGV.size
begin; p [133, (r133.nil?)]; rescue => e; p [133, :raised, e.class]; end
r134 = 2.5
begin; p [134, (r134.is_a?(Float))]; rescue => e; p [134, :raised, e.class]; end
r135 = -0.0 * (ARGV.size + 1)
begin; p [135, (r135.is_a?(Comparable))]; rescue => e; p [135, :raised, e.class]; end
r136 = Float::NAN + ARGV.size
begin; p [136, (r136.kind_of?(Numeric))]; rescue => e; p [136, :raised, e.class]; end
r137 = Float::INFINITY - ARGV.size
begin; p [137, (r137.instance_of?(Float))]; rescue => e; p [137, :raised, e.class]; end
r138 = ARGV.size - 3.75
begin; p [138, (r138.respond_to?(:nan?))]; rescue => e; p [138, :raised, e.class]; end
begin; p [139, (mf(1).respond_to?(:upcase))]; rescue => e; p [139, :raised, e.class]; end
r140 = ARGV.size == 9 ? nil : -0.5
begin; p [140, (r140.itself)]; rescue => e; p [140, :raised, e.class]; end
r141 = 1e20 + ARGV.size
begin; p [141, (r141.tap { |q| q })]; rescue => e; p [141, :raised, e.class]; end
r142 = 2.5
begin; p [142, (r142.then { |q| q + 1 })]; rescue => e; p [142, :raised, e.class]; end
r143 = -0.0 * (ARGV.size + 1)
begin; p [143, (r143.yield_self { |q| q * 2 })]; rescue => e; p [143, :raised, e.class]; end
r144 = Float::NAN + ARGV.size
begin; p [144, (r144.send(:+, 1))]; rescue => e; p [144, :raised, e.class]; end
r145 = Float::INFINITY - ARGV.size
begin; p [145, (r145.public_send(:abs))]; rescue => e; p [145, :raised, e.class]; end
begin; p [146, (mf(1).instance_variables)]; rescue => e; p [146, :raised, e.class]; end
r147 = ARGV.size == 9 ? nil : -0.5
begin; p [147, (r147 !~ /7/)]; rescue => e; p [147, :raised, e.class]; end
r148 = 1e20 + ARGV.size
begin; p [148, (r148 =~ /a/)]; rescue => e; p [148, :raised, e.class]; end
r149 = 2.5
begin; p [149, ([r149, 1].max)]; rescue => e; p [149, :raised, e.class]; end
r150 = -0.0 * (ARGV.size + 1)
begin; p [150, ([r150].sum)]; rescue => e; p [150, :raised, e.class]; end
r151 = Float::NAN + ARGV.size
begin; p [151, ([r151, 0.1].sum)]; rescue => e; p [151, :raised, e.class]; end
r152 = Float::INFINITY - ARGV.size
begin; p [152, (r152.to_s.size)]; rescue => e; p [152, :raised, e.class]; end
r153 = ARGV.size - 3.75
begin; p [153, ("x#{r153}y")]; rescue => e; p [153, :raised, e.class]; end
begin; p [154, (format("%.3f", mf(1)))]; rescue => e; p [154, :raised, e.class]; end
r155 = ARGV.size == 9 ? nil : -0.5
begin; p [155, (format("%g", r155))]; rescue => e; p [155, :raised, e.class]; end
r156 = 2.5
begin; p [156, (Integer(r156))]; rescue => e; p [156, :raised, e.class]; end
r157 = 2.5
begin; p [157, (Float(r157))]; rescue => e; p [157, :raised, e.class]; end
r158 = -0.0 * (ARGV.size + 1)
begin; p [158, (String(r158))]; rescue => e; p [158, :raised, e.class]; end
r159 = Float::NAN + ARGV.size
begin; p [159, (Array(r159))]; rescue => e; p [159, :raised, e.class]; end
r160 = Float::INFINITY - ARGV.size
begin; p [160, (!r160)]; rescue => e; p [160, :raised, e.class]; end
r161 = ARGV.size - 3.75
begin; p [161, (r161 && 1)]; rescue => e; p [161, :raised, e.class]; end
begin; p [162, (mf(1) || 1)]; rescue => e; p [162, :raised, e.class]; end
r163 = ARGV.size == 9 ? nil : -0.5
begin; p [163, (Math.sqrt(r163))]; rescue => e; p [163, :raised, e.class]; end
r164 = 1e20 + ARGV.size
begin; p [164, (Math.log(r164))]; rescue => e; p [164, :raised, e.class]; end
r165 = 2.5
begin; p [165, (r165.floor.class)]; rescue => e; p [165, :raised, e.class]; end
r166 = -0.0 * (ARGV.size + 1)
begin; p [166, (r166.round.class)]; rescue => e; p [166, :raised, e.class]; end
