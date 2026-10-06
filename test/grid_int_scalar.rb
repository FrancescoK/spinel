# spinel: int64
# frozen_string_literal: true
# Every Integer method on the unboxed representations: a plain sp_int scalar
# (literal, opaque -3, 0, 2**40) and the nilable sentinel (a local, and the
# value straight from a method), one probe per call, the receivers taken in
# turn.
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
def mi(k) = k == 0 ? nil : 7
def mn(k) = k == 0 ? nil : -3
r0 = ARGV.size - 3
begin; p [0, (r0 % 3)]; rescue => e; p [0, :raised, e.class]; end
r1 = ARGV.size
begin; p [1, (r1 % -2)]; rescue => e; p [1, :raised, e.class]; end
r2 = ARGV.size + 1099511627776
begin; p [2, (r2 % 0)]; rescue => e; p [2, :raised, e.class]; end
r3 = 7
begin; p [3, (r3 % 2.5)]; rescue => e; p [3, :raised, e.class]; end
r4 = ARGV.size == 9 ? nil : 7
begin; p [4, (r4 & 6)]; rescue => e; p [4, :raised, e.class]; end
begin; p [5, (mn(1) & -1)]; rescue => e; p [5, :raised, e.class]; end
r6 = ARGV.size - 3
begin; p [6, (r6 & 2.5)]; rescue => e; p [6, :raised, e.class]; end
r7 = ARGV.size
begin; p [7, (r7 * 3)]; rescue => e; p [7, :raised, e.class]; end
r8 = ARGV.size + 1099511627776
begin; p [8, (r8 * 2.5)]; rescue => e; p [8, :raised, e.class]; end
r9 = 7
begin; p [9, (r9 * 0)]; rescue => e; p [9, :raised, e.class]; end
r10 = ARGV.size == 9 ? nil : 7
begin; p [10, (r10 * r10)]; rescue => e; p [10, :raised, e.class]; end
r11 = ARGV.size
begin; p [11, (r11 * (2**62))]; rescue => e; p [11, :raised, e.class]; end
r12 = ARGV.size - 3
begin; p [12, (r12 ** 2)]; rescue => e; p [12, :raised, e.class]; end
r13 = ARGV.size
begin; p [13, (r13 ** -1)]; rescue => e; p [13, :raised, e.class]; end
r14 = ARGV.size + 1099511627776
begin; p [14, (r14 ** 0.5)]; rescue => e; p [14, :raised, e.class]; end
r15 = 7
begin; p [15, (r15 ** 0)]; rescue => e; p [15, :raised, e.class]; end
r16 = ARGV.size
begin; p [16, (r16 ** 70)]; rescue => e; p [16, :raised, e.class]; end
begin; p [17, (mn(1) + 1)]; rescue => e; p [17, :raised, e.class]; end
r18 = ARGV.size - 3
begin; p [18, (r18 + 1.5)]; rescue => e; p [18, :raised, e.class]; end
r19 = ARGV.size
begin; p [19, (r19 + nil)]; rescue => e; p [19, :raised, e.class]; end
r20 = ARGV.size + 1099511627776
begin; p [20, (r20 + "a")]; rescue => e; p [20, :raised, e.class]; end
r21 = 7
begin; p [21, (r21 + (2**62))]; rescue => e; p [21, :raised, e.class]; end
r22 = ARGV.size == 9 ? nil : 7
begin; p [22, (r22 - 1)]; rescue => e; p [22, :raised, e.class]; end
begin; p [23, (mn(1) - 2.5)]; rescue => e; p [23, :raised, e.class]; end
r24 = ARGV.size - 3
begin; p [24, (r24 - (2**63))]; rescue => e; p [24, :raised, e.class]; end
r25 = ARGV.size
begin; p [25, (-r25)]; rescue => e; p [25, :raised, e.class]; end
r26 = ARGV.size + 1099511627776
begin; p [26, (+r26)]; rescue => e; p [26, :raised, e.class]; end
r27 = 7
begin; p [27, (~r27)]; rescue => e; p [27, :raised, e.class]; end
r28 = ARGV.size == 9 ? nil : 7
begin; p [28, (r28 / 2)]; rescue => e; p [28, :raised, e.class]; end
begin; p [29, (mn(1) / -2)]; rescue => e; p [29, :raised, e.class]; end
r30 = ARGV.size - 3
begin; p [30, (r30 / 0)]; rescue => e; p [30, :raised, e.class]; end
r31 = ARGV.size
begin; p [31, (r31 / 2.0)]; rescue => e; p [31, :raised, e.class]; end
r32 = ARGV.size + 1099511627776
begin; p [32, (r32 / 0.0)]; rescue => e; p [32, :raised, e.class]; end
r33 = 7
begin; p [33, (r33 < 5)]; rescue => e; p [33, :raised, e.class]; end
r34 = ARGV.size == 9 ? nil : 7
begin; p [34, (r34 < 5.5)]; rescue => e; p [34, :raised, e.class]; end
begin; p [35, (mn(1) < "a")]; rescue => e; p [35, :raised, e.class]; end
r36 = ARGV.size - 3
begin; p [36, (r36 < nil)]; rescue => e; p [36, :raised, e.class]; end
r37 = ARGV.size
begin; p [37, (r37 << 2)]; rescue => e; p [37, :raised, e.class]; end
r38 = ARGV.size + 1099511627776
begin; p [38, (r38 << -1)]; rescue => e; p [38, :raised, e.class]; end
r39 = ARGV.size
begin; p [39, (r39 << 70)]; rescue => e; p [39, :raised, e.class]; end
r40 = ARGV.size == 9 ? nil : 7
begin; p [40, (r40 <= 7)]; rescue => e; p [40, :raised, e.class]; end
begin; p [41, (mn(1) <=> 3)]; rescue => e; p [41, :raised, e.class]; end
r42 = ARGV.size - 3
begin; p [42, (r42 <=> 3.5)]; rescue => e; p [42, :raised, e.class]; end
r43 = ARGV.size
begin; p [43, (r43 <=> "a")]; rescue => e; p [43, :raised, e.class]; end
r44 = ARGV.size + 1099511627776
begin; p [44, (r44 <=> nil)]; rescue => e; p [44, :raised, e.class]; end
r45 = 7
begin; p [45, (r45 <=> (2**70))]; rescue => e; p [45, :raised, e.class]; end
r46 = ARGV.size == 9 ? nil : 7
begin; p [46, (r46 == 7)]; rescue => e; p [46, :raised, e.class]; end
begin; p [47, (mn(1) == 7.0)]; rescue => e; p [47, :raised, e.class]; end
r48 = ARGV.size - 3
begin; p [48, (r48 == "7")]; rescue => e; p [48, :raised, e.class]; end
r49 = ARGV.size
begin; p [49, (r49 == nil)]; rescue => e; p [49, :raised, e.class]; end
r50 = ARGV.size + 1099511627776
begin; p [50, (r50 != 7)]; rescue => e; p [50, :raised, e.class]; end
r51 = 7
begin; p [51, (r51 === 7)]; rescue => e; p [51, :raised, e.class]; end
r52 = ARGV.size == 9 ? nil : 7
begin; p [52, (r52 === 7.0)]; rescue => e; p [52, :raised, e.class]; end
begin; p [53, (Integer === mn(1))]; rescue => e; p [53, :raised, e.class]; end
r54 = ARGV.size - 3
begin; p [54, ((1..10) === r54)]; rescue => e; p [54, :raised, e.class]; end
r55 = ARGV.size
begin; p [55, (r55 > 3)]; rescue => e; p [55, :raised, e.class]; end
r56 = ARGV.size + 1099511627776
begin; p [56, (r56 >= 7)]; rescue => e; p [56, :raised, e.class]; end
r57 = 7
begin; p [57, (r57 > 2.5)]; rescue => e; p [57, :raised, e.class]; end
r58 = ARGV.size == 9 ? nil : 7
begin; p [58, (r58 >> 1)]; rescue => e; p [58, :raised, e.class]; end
r59 = ARGV.size
begin; p [59, (r59[0])]; rescue => e; p [59, :raised, e.class]; end
r60 = ARGV.size + 1099511627776
begin; p [60, (r60[1])]; rescue => e; p [60, :raised, e.class]; end
r61 = 7
begin; p [61, (r61[100])]; rescue => e; p [61, :raised, e.class]; end
r62 = ARGV.size == 9 ? nil : 7
begin; p [62, (r62[0, 3])]; rescue => e; p [62, :raised, e.class]; end
begin; p [63, (mn(1)[0..2])]; rescue => e; p [63, :raised, e.class]; end
r64 = ARGV.size - 3
begin; p [64, (r64[-1])]; rescue => e; p [64, :raised, e.class]; end
r65 = ARGV.size
begin; p [65, (r65 ^ 5)]; rescue => e; p [65, :raised, e.class]; end
r66 = ARGV.size + 1099511627776
begin; p [66, (r66 | 8)]; rescue => e; p [66, :raised, e.class]; end
r67 = 7
begin; p [67, (r67 | -1)]; rescue => e; p [67, :raised, e.class]; end
r68 = ARGV.size == 9 ? nil : 7
begin; p [68, (r68.abs)]; rescue => e; p [68, :raised, e.class]; end
begin; p [69, (mn(1).magnitude)]; rescue => e; p [69, :raised, e.class]; end
r70 = ARGV.size - 3
begin; p [70, (r70.allbits?(3))]; rescue => e; p [70, :raised, e.class]; end
r71 = ARGV.size
begin; p [71, (r71.anybits?(3))]; rescue => e; p [71, :raised, e.class]; end
r72 = ARGV.size + 1099511627776
begin; p [72, (r72.nobits?(8))]; rescue => e; p [72, :raised, e.class]; end
r73 = 7
begin; p [73, (r73.bit_length)]; rescue => e; p [73, :raised, e.class]; end
r74 = ARGV.size == 9 ? nil : 7
begin; p [74, (r74.ceil)]; rescue => e; p [74, :raised, e.class]; end
begin; p [75, (mn(1).ceil(-1))]; rescue => e; p [75, :raised, e.class]; end
r76 = ARGV.size - 3
begin; p [76, (r76.ceil(2))]; rescue => e; p [76, :raised, e.class]; end
r77 = ARGV.size
begin; p [77, (r77.floor)]; rescue => e; p [77, :raised, e.class]; end
r78 = ARGV.size + 1099511627776
begin; p [78, (r78.floor(-1))]; rescue => e; p [78, :raised, e.class]; end
r79 = 7
begin; p [79, (r79.floor(1))]; rescue => e; p [79, :raised, e.class]; end
r80 = ARGV.size == 9 ? nil : 7
begin; p [80, (r80.round)]; rescue => e; p [80, :raised, e.class]; end
begin; p [81, (mn(1).round(-1))]; rescue => e; p [81, :raised, e.class]; end
r82 = ARGV.size - 3
begin; p [82, (r82.round(1))]; rescue => e; p [82, :raised, e.class]; end
r83 = ARGV.size
begin; p [83, (r83.round(-1, half: :even))]; rescue => e; p [83, :raised, e.class]; end
r84 = ARGV.size + 1099511627776
begin; p [84, (r84.round(-1, half: :down))]; rescue => e; p [84, :raised, e.class]; end
r85 = 7
begin; p [85, (r85.round(half: :up))]; rescue => e; p [85, :raised, e.class]; end
r86 = ARGV.size == 9 ? nil : 7
begin; p [86, (r86.truncate)]; rescue => e; p [86, :raised, e.class]; end
begin; p [87, (mn(1).truncate(-1))]; rescue => e; p [87, :raised, e.class]; end
r88 = ARGV.size - 3
begin; p [88, (r88.ceildiv(2))]; rescue => e; p [88, :raised, e.class]; end
r89 = ARGV.size
begin; p [89, (r89.ceildiv(-2))]; rescue => e; p [89, :raised, e.class]; end
r90 = ARGV.size + 1099511627776
begin; p [90, (r90.chr)]; rescue => e; p [90, :raised, e.class]; end
r91 = 7
begin; p [91, (r91.chr(Encoding::UTF_8))]; rescue => e; p [91, :raised, e.class]; end
r92 = ARGV.size == 9 ? nil : 7
begin; p [92, (r92.coerce(2))]; rescue => e; p [92, :raised, e.class]; end
begin; p [93, (mn(1).coerce(2.5))]; rescue => e; p [93, :raised, e.class]; end
r94 = ARGV.size - 3
begin; p [94, (r94.denominator)]; rescue => e; p [94, :raised, e.class]; end
r95 = ARGV.size
begin; p [95, (r95.numerator)]; rescue => e; p [95, :raised, e.class]; end
r96 = ARGV.size + 1099511627776
begin; p [96, (r96.digits)]; rescue => e; p [96, :raised, e.class]; end
r97 = 7
begin; p [97, (r97.digits(16))]; rescue => e; p [97, :raised, e.class]; end
r98 = ARGV.size == 9 ? nil : 7
begin; p [98, (r98.digits(1))]; rescue => e; p [98, :raised, e.class]; end
begin; p [99, (mn(1).div(2))]; rescue => e; p [99, :raised, e.class]; end
r100 = ARGV.size - 3
begin; p [100, (r100.div(2.5))]; rescue => e; p [100, :raised, e.class]; end
r101 = ARGV.size
begin; p [101, (r101.div(0))]; rescue => e; p [101, :raised, e.class]; end
r102 = ARGV.size + 1099511627776
begin; p [102, (r102.div(-2))]; rescue => e; p [102, :raised, e.class]; end
r103 = 7
begin; p [103, (r103.divmod(3))]; rescue => e; p [103, :raised, e.class]; end
r104 = ARGV.size == 9 ? nil : 7
begin; p [104, (r104.divmod(-3))]; rescue => e; p [104, :raised, e.class]; end
begin; p [105, (mn(1).divmod(2.5))]; rescue => e; p [105, :raised, e.class]; end
r106 = ARGV.size - 3
begin; p [106, (r106.divmod(0))]; rescue => e; p [106, :raised, e.class]; end
r107 = ARGV.size
begin; p [107, (r107.downto(5).to_a)]; rescue => e; p [107, :raised, e.class]; end
r108 = 7
begin; p [108, (r108.downto(5) { |i| i })]; rescue => e; p [108, :raised, e.class]; end
r109 = 7
begin; p [109, (r109.upto(9).to_a)]; rescue => e; p [109, :raised, e.class]; end
r110 = ARGV.size == 9 ? nil : 7
begin; p [110, (r110.upto(9) { |i| i })]; rescue => e; p [110, :raised, e.class]; end
begin; p [111, (mn(1).even?)]; rescue => e; p [111, :raised, e.class]; end
r112 = ARGV.size - 3
begin; p [112, (r112.odd?)]; rescue => e; p [112, :raised, e.class]; end
r113 = ARGV.size
begin; p [113, (r113.zero?)]; rescue => e; p [113, :raised, e.class]; end
r114 = ARGV.size + 1099511627776
begin; p [114, (r114.nonzero?)]; rescue => e; p [114, :raised, e.class]; end
r115 = 7
begin; p [115, (r115.positive?)]; rescue => e; p [115, :raised, e.class]; end
r116 = ARGV.size == 9 ? nil : 7
begin; p [116, (r116.negative?)]; rescue => e; p [116, :raised, e.class]; end
begin; p [117, (mn(1).fdiv(2))]; rescue => e; p [117, :raised, e.class]; end
r118 = ARGV.size - 3
begin; p [118, (r118.fdiv(0))]; rescue => e; p [118, :raised, e.class]; end
r119 = ARGV.size
begin; p [119, (r119.gcd(4))]; rescue => e; p [119, :raised, e.class]; end
r120 = ARGV.size + 1099511627776
begin; p [120, (r120.lcm(4))]; rescue => e; p [120, :raised, e.class]; end
r121 = 7
begin; p [121, (r121.gcdlcm(4))]; rescue => e; p [121, :raised, e.class]; end
r122 = ARGV.size == 9 ? nil : 7
begin; p [122, (r122.gcd(0))]; rescue => e; p [122, :raised, e.class]; end
begin; p [123, (mn(1).inspect)]; rescue => e; p [123, :raised, e.class]; end
r124 = ARGV.size - 3
begin; p [124, (r124.to_s)]; rescue => e; p [124, :raised, e.class]; end
r125 = ARGV.size
begin; p [125, (r125.to_s(2))]; rescue => e; p [125, :raised, e.class]; end
r126 = ARGV.size + 1099511627776
begin; p [126, (r126.to_s(16))]; rescue => e; p [126, :raised, e.class]; end
r127 = 7
begin; p [127, (r127.to_s(36))]; rescue => e; p [127, :raised, e.class]; end
r128 = ARGV.size == 9 ? nil : 7
begin; p [128, (r128.to_s(1))]; rescue => e; p [128, :raised, e.class]; end
begin; p [129, (mn(1).integer?)]; rescue => e; p [129, :raised, e.class]; end
r130 = ARGV.size - 3
begin; p [130, (r130.finite?)]; rescue => e; p [130, :raised, e.class]; end
r131 = ARGV.size
begin; p [131, (r131.infinite?)]; rescue => e; p [131, :raised, e.class]; end
r132 = ARGV.size + 1099511627776
begin; p [132, (r132.modulo(3))]; rescue => e; p [132, :raised, e.class]; end
r133 = 7
begin; p [133, (r133.remainder(3))]; rescue => e; p [133, :raised, e.class]; end
r134 = ARGV.size == 9 ? nil : 7
begin; p [134, (r134.remainder(-3))]; rescue => e; p [134, :raised, e.class]; end
begin; p [135, (mn(1).remainder(2.5))]; rescue => e; p [135, :raised, e.class]; end
r136 = ARGV.size - 3
begin; p [136, (r136.next)]; rescue => e; p [136, :raised, e.class]; end
r137 = ARGV.size
begin; p [137, (r137.succ)]; rescue => e; p [137, :raised, e.class]; end
r138 = ARGV.size + 1099511627776
begin; p [138, (r138.pred)]; rescue => e; p [138, :raised, e.class]; end
r139 = 7
begin; p [139, (r139.ord)]; rescue => e; p [139, :raised, e.class]; end
r140 = ARGV.size == 9 ? nil : 7
begin; p [140, (r140.pow(2))]; rescue => e; p [140, :raised, e.class]; end
begin; p [141, (mn(1).pow(2, 5))]; rescue => e; p [141, :raised, e.class]; end
r142 = ARGV.size - 3
begin; p [142, (r142.pow(3, -4))]; rescue => e; p [142, :raised, e.class]; end
r143 = ARGV.size + 1099511627776
begin; p [143, (r143.pow(-1))]; rescue => e; p [143, :raised, e.class]; end
r144 = ARGV.size + 1099511627776
begin; p [144, (r144.rationalize)]; rescue => e; p [144, :raised, e.class]; end
r145 = 7
begin; p [145, (r145.to_r)]; rescue => e; p [145, :raised, e.class]; end
r146 = ARGV.size == 9 ? nil : 7
begin; p [146, (r146.to_c)]; rescue => e; p [146, :raised, e.class]; end
begin; p [147, (mn(1).size)]; rescue => e; p [147, :raised, e.class]; end
r148 = ARGV.size - 3
begin; p [148, (r148.times.to_a)]; rescue => e; p [148, :raised, e.class]; end
r149 = ARGV.size
begin; p [149, (r149.times { |i| i })]; rescue => e; p [149, :raised, e.class]; end
r150 = 7
begin; p [150, (r150.times.sum)]; rescue => e; p [150, :raised, e.class]; end
r151 = 7
begin; p [151, (r151.times.map { |i| i * 2 })]; rescue => e; p [151, :raised, e.class]; end
r152 = ARGV.size == 9 ? nil : 7
begin; p [152, (r152.to_f)]; rescue => e; p [152, :raised, e.class]; end
begin; p [153, (mn(1).to_i)]; rescue => e; p [153, :raised, e.class]; end
r154 = ARGV.size - 3
begin; p [154, (r154.to_int)]; rescue => e; p [154, :raised, e.class]; end
r155 = ARGV.size
begin; p [155, (r155.abs2)]; rescue => e; p [155, :raised, e.class]; end
r156 = ARGV.size + 1099511627776
begin; p [156, (r156.angle)]; rescue => e; p [156, :raised, e.class]; end
r157 = 7
begin; p [157, (r157.arg)]; rescue => e; p [157, :raised, e.class]; end
r158 = ARGV.size == 9 ? nil : 7
begin; p [158, (r158.phase)]; rescue => e; p [158, :raised, e.class]; end
begin; p [159, (mn(1).conj)]; rescue => e; p [159, :raised, e.class]; end
r160 = ARGV.size - 3
begin; p [160, (r160.real)]; rescue => e; p [160, :raised, e.class]; end
r161 = ARGV.size
begin; p [161, (r161.imag)]; rescue => e; p [161, :raised, e.class]; end
r162 = ARGV.size + 1099511627776
begin; p [162, (r162.real?)]; rescue => e; p [162, :raised, e.class]; end
r163 = 7
begin; p [163, (r163.rect)]; rescue => e; p [163, :raised, e.class]; end
r164 = ARGV.size == 9 ? nil : 7
begin; p [164, (r164.polar)]; rescue => e; p [164, :raised, e.class]; end
r165 = ARGV.size - 3
begin; p [165, (r165.quo(2))]; rescue => e; p [165, :raised, e.class]; end
r166 = ARGV.size
begin; p [166, (r166.quo(2.0))]; rescue => e; p [166, :raised, e.class]; end
r167 = 7
begin; p [167, (r167.step(10, 2).to_a)]; rescue => e; p [167, :raised, e.class]; end
r168 = 7
begin; p [168, (r168.step(10, 2) { |i| i })]; rescue => e; p [168, :raised, e.class]; end
r169 = ARGV.size == 9 ? nil : 7
begin; p [169, (r169.step(by: 2, to: 10).to_a)]; rescue => e; p [169, :raised, e.class]; end
begin; p [170, (mn(1).step(1, -2).to_a)]; rescue => e; p [170, :raised, e.class]; end
r171 = ARGV.size - 3
begin; p [171, (r171.eql?(7))]; rescue => e; p [171, :raised, e.class]; end
r172 = ARGV.size
begin; p [172, (r172.eql?(7.0))]; rescue => e; p [172, :raised, e.class]; end
r173 = ARGV.size + 1099511627776
begin; p [173, (r173.equal?(7))]; rescue => e; p [173, :raised, e.class]; end
r174 = 7
begin; p [174, (r174.clone)]; rescue => e; p [174, :raised, e.class]; end
r175 = ARGV.size == 9 ? nil : 7
begin; p [175, (r175.dup)]; rescue => e; p [175, :raised, e.class]; end
begin; p [176, (mn(1).freeze)]; rescue => e; p [176, :raised, e.class]; end
r177 = ARGV.size - 3
begin; p [177, (r177.frozen?)]; rescue => e; p [177, :raised, e.class]; end
r178 = ARGV.size
begin; p [178, (r178.between?(1, 10))]; rescue => e; p [178, :raised, e.class]; end
r179 = ARGV.size + 1099511627776
begin; p [179, (r179.clamp(1, 5))]; rescue => e; p [179, :raised, e.class]; end
r180 = 7
begin; p [180, (r180.clamp(..5))]; rescue => e; p [180, :raised, e.class]; end
r181 = ARGV.size == 9 ? nil : 7
begin; p [181, (r181.clamp(8, 9))]; rescue => e; p [181, :raised, e.class]; end
begin; p [182, (mn(1).clamp(5, 1))]; rescue => e; p [182, :raised, e.class]; end
r183 = ARGV.size - 3
begin; p [183, (r183.class)]; rescue => e; p [183, :raised, e.class]; end
r184 = ARGV.size
begin; p [184, (r184.nil?)]; rescue => e; p [184, :raised, e.class]; end
r185 = ARGV.size + 1099511627776
begin; p [185, (r185.is_a?(Integer))]; rescue => e; p [185, :raised, e.class]; end
r186 = 7
begin; p [186, (r186.is_a?(Comparable))]; rescue => e; p [186, :raised, e.class]; end
r187 = ARGV.size == 9 ? nil : 7
begin; p [187, (r187.kind_of?(Numeric))]; rescue => e; p [187, :raised, e.class]; end
begin; p [188, (mn(1).instance_of?(Integer))]; rescue => e; p [188, :raised, e.class]; end
r189 = ARGV.size
begin; p [189, (r189.respond_to?(:abs))]; rescue => e; p [189, :raised, e.class]; end
r190 = ARGV.size + 1099511627776
begin; p [190, (r190.respond_to?(:upcase))]; rescue => e; p [190, :raised, e.class]; end
r191 = 7
begin; p [191, (r191.itself)]; rescue => e; p [191, :raised, e.class]; end
r192 = ARGV.size == 9 ? nil : 7
begin; p [192, (r192.tap { |q| q })]; rescue => e; p [192, :raised, e.class]; end
begin; p [193, (mn(1).then { |q| q + 1 })]; rescue => e; p [193, :raised, e.class]; end
r194 = ARGV.size - 3
begin; p [194, (r194.yield_self { |q| q * 2 })]; rescue => e; p [194, :raised, e.class]; end
r195 = ARGV.size
begin; p [195, (r195.send(:+, 1))]; rescue => e; p [195, :raised, e.class]; end
r196 = ARGV.size + 1099511627776
begin; p [196, (r196.public_send(:abs))]; rescue => e; p [196, :raised, e.class]; end
r197 = ARGV.size == 9 ? nil : 7
begin; p [197, (r197.hash == (r197 + 0).hash)]; rescue => e; p [197, :raised, e.class]; end
begin; p [198, (mn(1).object_id == mn(1).object_id)]; rescue => e; p [198, :raised, e.class]; end
r199 = ARGV.size - 3
begin; p [199, (r199.instance_variables)]; rescue => e; p [199, :raised, e.class]; end
r200 = ARGV.size
begin; p [200, (r200.to_enum(:times).to_a)]; rescue => e; p [200, :raised, e.class]; end
r201 = ARGV.size + 1099511627776
begin; p [201, (r201 !~ /7/)]; rescue => e; p [201, :raised, e.class]; end
r202 = 7
begin; p [202, (r202 =~ /a/)]; rescue => e; p [202, :raised, e.class]; end
r203 = ARGV.size == 9 ? nil : 7
begin; p [203, (r203.instance_variable_get(:@x))]; rescue => e; p [203, :raised, e.class]; end
begin; p [204, ([mn(1), 1].max)]; rescue => e; p [204, :raised, e.class]; end
r205 = ARGV.size - 3
begin; p [205, ([r205].sum)]; rescue => e; p [205, :raised, e.class]; end
r206 = ARGV.size
begin; p [206, (r206.to_s.size)]; rescue => e; p [206, :raised, e.class]; end
r207 = ARGV.size + 1099511627776
begin; p [207, ("x#{r207}y")]; rescue => e; p [207, :raised, e.class]; end
r208 = 7
begin; p [208, (format("%05d", r208))]; rescue => e; p [208, :raised, e.class]; end
r209 = ARGV.size == 9 ? nil : 7
begin; p [209, (Integer(r209))]; rescue => e; p [209, :raised, e.class]; end
begin; p [210, (Float(mn(1)))]; rescue => e; p [210, :raised, e.class]; end
r211 = ARGV.size - 3
begin; p [211, (String(r211))]; rescue => e; p [211, :raised, e.class]; end
r212 = ARGV.size
begin; p [212, (Array(r212))]; rescue => e; p [212, :raised, e.class]; end
r213 = ARGV.size + 1099511627776
begin; p [213, (r213.zero? ? :z : :nz)]; rescue => e; p [213, :raised, e.class]; end
r214 = 7
begin; p [214, (!r214)]; rescue => e; p [214, :raised, e.class]; end
r215 = ARGV.size == 9 ? nil : 7
begin; p [215, (r215 && 1)]; rescue => e; p [215, :raised, e.class]; end
begin; p [216, (mn(1) || 1)]; rescue => e; p [216, :raised, e.class]; end
