# frozen_string_literal: true
# The Array methods that keep an array of one user class in its
# object-array representation (sp_PtrArray, obj_array:K) -- every other
# call widens the local to a poly array, which grid_array_typed covers.
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
r0 = [K.new(3), K.new(1), K.new(2)]
begin; p [0, (r0 << K.new(4)), r0.map { |q| q.v }]; rescue => e; p [0, :raised, e.class]; end
r1 = [K.new(3), K.new(1), K.new(2)]
begin; p [1, (r1[0]), r1.map { |q| q.v }]; rescue => e; p [1, :raised, e.class]; end
r2 = [K.new(3), K.new(1), K.new(2)]
begin; p [2, (r2[-1]), r2.map { |q| q.v }]; rescue => e; p [2, :raised, e.class]; end
r3 = [K.new(3), K.new(1), K.new(2)]
begin; p [3, (r3[1]), r3.map { |q| q.v }]; rescue => e; p [3, :raised, e.class]; end
r4 = [K.new(3), K.new(1), K.new(2)]
begin; p [4, (r4[9]), r4.map { |q| q.v }]; rescue => e; p [4, :raised, e.class]; end
r5 = [K.new(3), K.new(1), K.new(2)]
begin; p [5, (r5[-9]), r5.map { |q| q.v }]; rescue => e; p [5, :raised, e.class]; end
r6 = [K.new(3), K.new(1), K.new(2)]
begin; p [6, (r6[1.5]), r6.map { |q| q.v }]; rescue => e; p [6, :raised, e.class]; end
r7 = [K.new(3), K.new(1), K.new(2)]
begin; p [7, (r7["a"]), r7.map { |q| q.v }]; rescue => e; p [7, :raised, e.class]; end
r8 = [K.new(3), K.new(1), K.new(2)]
begin; p [8, (r8[0] = K.new(4)), r8.map { |q| q.v }]; rescue => e; p [8, :raised, e.class]; end
r9 = [K.new(3), K.new(1), K.new(2)]
begin; p [9, (r9[-9] = K.new(4)), r9.map { |q| q.v }]; rescue => e; p [9, :raised, e.class]; end
r10 = [K.new(3), K.new(1), K.new(2)]
begin; p [10, (r10.at(0)), r10.map { |q| q.v }]; rescue => e; p [10, :raised, e.class]; end
r11 = [K.new(3), K.new(1), K.new(2)]
begin; p [11, (r11.at(-1)), r11.map { |q| q.v }]; rescue => e; p [11, :raised, e.class]; end
r12 = [K.new(3), K.new(1), K.new(2)]
begin; p [12, (r12.at(9)), r12.map { |q| q.v }]; rescue => e; p [12, :raised, e.class]; end
r13 = [K.new(3), K.new(1), K.new(2)]
begin; p [13, (r13.first), r13.map { |q| q.v }]; rescue => e; p [13, :raised, e.class]; end
r14 = [K.new(3), K.new(1), K.new(2)]
begin; p [14, (r14.last), r14.map { |q| q.v }]; rescue => e; p [14, :raised, e.class]; end
r15 = [K.new(3), K.new(1), K.new(2)]
begin; p [15, (r15.all? { |x| x == K.new(1) }), r15.map { |q| q.v }]; rescue => e; p [15, :raised, e.class]; end
r16 = [K.new(3), K.new(1), K.new(2)]
begin; p [16, (r16.any? { |x| x == K.new(1) }), r16.map { |q| q.v }]; rescue => e; p [16, :raised, e.class]; end
r17 = [K.new(3), K.new(1), K.new(2)]
begin; p [17, (r17.none? { |x| x == K.new(1) }), r17.map { |q| q.v }]; rescue => e; p [17, :raised, e.class]; end
r18 = [K.new(3), K.new(1), K.new(2)]
begin; p [18, (r18.one? { |x| x == K.new(1) }), r18.map { |q| q.v }]; rescue => e; p [18, :raised, e.class]; end
r19 = [K.new(3), K.new(1), K.new(2)]
begin; p [19, (r19.find { |x| x == K.new(1) }), r19.map { |q| q.v }]; rescue => e; p [19, :raised, e.class]; end
r20 = [K.new(3), K.new(1), K.new(2)]
begin; p [20, (r20.detect { |x| x == K.new(9) }), r20.map { |q| q.v }]; rescue => e; p [20, :raised, e.class]; end
r21 = [K.new(3), K.new(1), K.new(2)]
begin; p [21, (r21.count { |x| x == K.new(1) }), r21.map { |q| q.v }]; rescue => e; p [21, :raised, e.class]; end
r22 = [K.new(3), K.new(1), K.new(2)]
begin; p [22, (r22.empty?), r22.map { |q| q.v }]; rescue => e; p [22, :raised, e.class]; end
r23 = [K.new(3), K.new(1), K.new(2)]
begin; p [23, (r23.length), r23.map { |q| q.v }]; rescue => e; p [23, :raised, e.class]; end
r24 = [K.new(3), K.new(1), K.new(2)]
begin; p [24, (r24.size), r24.map { |q| q.v }]; rescue => e; p [24, :raised, e.class]; end
r25 = [K.new(3), K.new(1), K.new(2)]
begin; p [25, (r25.append(K.new(4))), r25.map { |q| q.v }]; rescue => e; p [25, :raised, e.class]; end
r26 = [K.new(3), K.new(1), K.new(2)]
begin; p [26, (r26.push(K.new(4), K.new(4))), r26.map { |q| q.v }]; rescue => e; p [26, :raised, e.class]; end
r27 = [K.new(3), K.new(1), K.new(2)]
begin; p [27, (r27.sort!), r27.map { |q| q.v }]; rescue => e; p [27, :raised, e.class]; end
r28 = [K.new(3), K.new(1), K.new(2)]
begin; p [28, (r28.sort), r28.map { |q| q.v }]; rescue => e; p [28, :raised, e.class]; end
r29 = [K.new(3), K.new(1), K.new(2)]
begin; p [29, (r29.min), r29.map { |q| q.v }]; rescue => e; p [29, :raised, e.class]; end
r30 = [K.new(3), K.new(1), K.new(2)]
begin; p [30, (r30.max), r30.map { |q| q.v }]; rescue => e; p [30, :raised, e.class]; end
r31 = [K.new(3), K.new(1), K.new(2)]
begin; p [31, (r31.max_by { |x| x }), r31.map { |q| q.v }]; rescue => e; p [31, :raised, e.class]; end
r32 = [K.new(3), K.new(1), K.new(2)]
begin; p [32, (r32.min_by { |x| x }), r32.map { |q| q.v }]; rescue => e; p [32, :raised, e.class]; end
r33 = [K.new(3), K.new(1), K.new(2)]
begin; p [33, (r33.minmax_by { |x| x }), r33.map { |q| q.v }]; rescue => e; p [33, :raised, e.class]; end
r34 = [K.new(3), K.new(1), K.new(2)]
begin; p [34, (r34.sum { |x| 1 }), r34.map { |q| q.v }]; rescue => e; p [34, :raised, e.class]; end
r35 = [K.new(3), K.new(1), K.new(2)]
begin; p [35, (r35.take_while { |x| x != K.new(9) }), r35.map { |q| q.v }]; rescue => e; p [35, :raised, e.class]; end
r36 = [K.new(3), K.new(1), K.new(2)]
begin; p [36, (r36.drop_while { |x| x == K.new(1) }), r36.map { |q| q.v }]; rescue => e; p [36, :raised, e.class]; end
r37 = [K.new(3), K.new(1), K.new(2)]
begin; p [37, (r37.map { |x| x }), r37.map { |q| q.v }]; rescue => e; p [37, :raised, e.class]; end
r38 = [K.new(3), K.new(1), K.new(2)]
begin; p [38, (r38.collect { |x| [x] }), r38.map { |q| q.v }]; rescue => e; p [38, :raised, e.class]; end
r39 = [K.new(3), K.new(1), K.new(2)]
begin; p [39, (r39.flat_map { |x| [x, x] }), r39.map { |q| q.v }]; rescue => e; p [39, :raised, e.class]; end
r40 = [K.new(3), K.new(1), K.new(2)]
begin; p [40, (r40.collect_concat { |x| [x] }), r40.map { |q| q.v }]; rescue => e; p [40, :raised, e.class]; end
r41 = [K.new(3), K.new(1), K.new(2)]
begin; p [41, (r41.filter_map { |x| x if x == K.new(1) }), r41.map { |q| q.v }]; rescue => e; p [41, :raised, e.class]; end
r42 = [K.new(3), K.new(1), K.new(2)]
begin; p [42, (r42.partition { |x| x == K.new(1) }), r42.map { |q| q.v }]; rescue => e; p [42, :raised, e.class]; end
r43 = [K.new(3), K.new(1), K.new(2)]
begin; p [43, (r43.group_by { |x| x }), r43.map { |q| q.v }]; rescue => e; p [43, :raised, e.class]; end
r44 = [K.new(3), K.new(1), K.new(2)]
begin; p [44, (r44.each_with_object([]) { |x, acc| acc << x }), r44.map { |q| q.v }]; rescue => e; p [44, :raised, e.class]; end
r45 = [K.new(3), K.new(1), K.new(2)]
begin; p [45, (r45.inject { |a, b| a }), r45.map { |q| q.v }]; rescue => e; p [45, :raised, e.class]; end
r46 = [K.new(3), K.new(1), K.new(2)]
begin; p [46, (r46.tally), r46.map { |q| q.v }]; rescue => e; p [46, :raised, e.class]; end
r47 = [K.new(3), K.new(1), K.new(2)]
begin; p [47, (r47.to_h { |x| [x, 1] }), r47.map { |q| q.v }]; rescue => e; p [47, :raised, e.class]; end
r48 = [K.new(3), K.new(1), K.new(2)]
begin; p [48, (r48.each_with_index { |x, i| x }), r48.map { |q| q.v }]; rescue => e; p [48, :raised, e.class]; end
r49 = [K.new(3), K.new(1), K.new(2)]
begin; p [49, (r49.send(:size)), r49.map { |q| q.v }]; rescue => e; p [49, :raised, e.class]; end
r50 = [K.new(3), K.new(1), K.new(2)]
begin; p [50, (r50.public_send(:first)), r50.map { |q| q.v }]; rescue => e; p [50, :raised, e.class]; end
r51 = [K.new(3), K.new(1), K.new(2)]
begin; p [51, (r51.map(&:to_s)), r51.map { |q| q.v }]; rescue => e; p [51, :raised, e.class]; end
r52 = [K.new(3), K.new(1), K.new(2)]
begin; p [52, (r52.max.class), r52.map { |q| q.v }]; rescue => e; p [52, :raised, e.class]; end
r53 = [K.new(3), K.new(1), K.new(2)]
begin; p [53, (r53.first.class), r53.map { |q| q.v }]; rescue => e; p [53, :raised, e.class]; end
r54 = [K.new(5)]
begin; p [54, (r54 << K.new(4)), r54.map { |q| q.v }]; rescue => e; p [54, :raised, e.class]; end
r55 = [K.new(5)]
begin; p [55, (r55[0]), r55.map { |q| q.v }]; rescue => e; p [55, :raised, e.class]; end
r56 = [K.new(5)]
begin; p [56, (r56[-1]), r56.map { |q| q.v }]; rescue => e; p [56, :raised, e.class]; end
r57 = [K.new(5)]
begin; p [57, (r57[1]), r57.map { |q| q.v }]; rescue => e; p [57, :raised, e.class]; end
r58 = [K.new(5)]
begin; p [58, (r58[9]), r58.map { |q| q.v }]; rescue => e; p [58, :raised, e.class]; end
r59 = [K.new(5)]
begin; p [59, (r59[-9]), r59.map { |q| q.v }]; rescue => e; p [59, :raised, e.class]; end
r60 = [K.new(5)]
begin; p [60, (r60[1.5]), r60.map { |q| q.v }]; rescue => e; p [60, :raised, e.class]; end
r61 = [K.new(5)]
begin; p [61, (r61["a"]), r61.map { |q| q.v }]; rescue => e; p [61, :raised, e.class]; end
r62 = [K.new(5)]
begin; p [62, (r62[0] = K.new(4)), r62.map { |q| q.v }]; rescue => e; p [62, :raised, e.class]; end
r63 = [K.new(5)]
begin; p [63, (r63[-9] = K.new(4)), r63.map { |q| q.v }]; rescue => e; p [63, :raised, e.class]; end
r64 = [K.new(5)]
begin; p [64, (r64.at(0)), r64.map { |q| q.v }]; rescue => e; p [64, :raised, e.class]; end
r65 = [K.new(5)]
begin; p [65, (r65.at(-1)), r65.map { |q| q.v }]; rescue => e; p [65, :raised, e.class]; end
r66 = [K.new(5)]
begin; p [66, (r66.at(9)), r66.map { |q| q.v }]; rescue => e; p [66, :raised, e.class]; end
r67 = [K.new(5)]
begin; p [67, (r67.first), r67.map { |q| q.v }]; rescue => e; p [67, :raised, e.class]; end
r68 = [K.new(5)]
begin; p [68, (r68.last), r68.map { |q| q.v }]; rescue => e; p [68, :raised, e.class]; end
r69 = [K.new(5)]
begin; p [69, (r69.all? { |x| x == K.new(5) }), r69.map { |q| q.v }]; rescue => e; p [69, :raised, e.class]; end
r70 = [K.new(5)]
begin; p [70, (r70.any? { |x| x == K.new(5) }), r70.map { |q| q.v }]; rescue => e; p [70, :raised, e.class]; end
r71 = [K.new(5)]
begin; p [71, (r71.none? { |x| x == K.new(5) }), r71.map { |q| q.v }]; rescue => e; p [71, :raised, e.class]; end
r72 = [K.new(5)]
begin; p [72, (r72.one? { |x| x == K.new(5) }), r72.map { |q| q.v }]; rescue => e; p [72, :raised, e.class]; end
r73 = [K.new(5)]
begin; p [73, (r73.find { |x| x == K.new(5) }), r73.map { |q| q.v }]; rescue => e; p [73, :raised, e.class]; end
r74 = [K.new(5)]
begin; p [74, (r74.detect { |x| x == K.new(9) }), r74.map { |q| q.v }]; rescue => e; p [74, :raised, e.class]; end
r75 = [K.new(5)]
begin; p [75, (r75.count { |x| x == K.new(5) }), r75.map { |q| q.v }]; rescue => e; p [75, :raised, e.class]; end
r76 = [K.new(5)]
begin; p [76, (r76.empty?), r76.map { |q| q.v }]; rescue => e; p [76, :raised, e.class]; end
r77 = [K.new(5)]
begin; p [77, (r77.length), r77.map { |q| q.v }]; rescue => e; p [77, :raised, e.class]; end
r78 = [K.new(5)]
begin; p [78, (r78.size), r78.map { |q| q.v }]; rescue => e; p [78, :raised, e.class]; end
r79 = [K.new(5)]
begin; p [79, (r79.append(K.new(4))), r79.map { |q| q.v }]; rescue => e; p [79, :raised, e.class]; end
r80 = [K.new(5)]
begin; p [80, (r80.push(K.new(4), K.new(4))), r80.map { |q| q.v }]; rescue => e; p [80, :raised, e.class]; end
r81 = [K.new(5)]
begin; p [81, (r81.sort!), r81.map { |q| q.v }]; rescue => e; p [81, :raised, e.class]; end
r82 = [K.new(5)]
begin; p [82, (r82.sort), r82.map { |q| q.v }]; rescue => e; p [82, :raised, e.class]; end
r83 = [K.new(5)]
begin; p [83, (r83.min), r83.map { |q| q.v }]; rescue => e; p [83, :raised, e.class]; end
r84 = [K.new(5)]
begin; p [84, (r84.max), r84.map { |q| q.v }]; rescue => e; p [84, :raised, e.class]; end
r85 = [K.new(5)]
begin; p [85, (r85.max_by { |x| x }), r85.map { |q| q.v }]; rescue => e; p [85, :raised, e.class]; end
r86 = [K.new(5)]
begin; p [86, (r86.min_by { |x| x }), r86.map { |q| q.v }]; rescue => e; p [86, :raised, e.class]; end
r87 = [K.new(5)]
begin; p [87, (r87.minmax_by { |x| x }), r87.map { |q| q.v }]; rescue => e; p [87, :raised, e.class]; end
r88 = [K.new(5)]
begin; p [88, (r88.sum { |x| 1 }), r88.map { |q| q.v }]; rescue => e; p [88, :raised, e.class]; end
r89 = [K.new(5)]
begin; p [89, (r89.take_while { |x| x != K.new(9) }), r89.map { |q| q.v }]; rescue => e; p [89, :raised, e.class]; end
r90 = [K.new(5)]
begin; p [90, (r90.drop_while { |x| x == K.new(5) }), r90.map { |q| q.v }]; rescue => e; p [90, :raised, e.class]; end
r91 = [K.new(5)]
begin; p [91, (r91.map { |x| x }), r91.map { |q| q.v }]; rescue => e; p [91, :raised, e.class]; end
r92 = [K.new(5)]
begin; p [92, (r92.collect { |x| [x] }), r92.map { |q| q.v }]; rescue => e; p [92, :raised, e.class]; end
r93 = [K.new(5)]
begin; p [93, (r93.flat_map { |x| [x, x] }), r93.map { |q| q.v }]; rescue => e; p [93, :raised, e.class]; end
r94 = [K.new(5)]
begin; p [94, (r94.collect_concat { |x| [x] }), r94.map { |q| q.v }]; rescue => e; p [94, :raised, e.class]; end
r95 = [K.new(5)]
begin; p [95, (r95.filter_map { |x| x if x == K.new(5) }), r95.map { |q| q.v }]; rescue => e; p [95, :raised, e.class]; end
r96 = [K.new(5)]
begin; p [96, (r96.partition { |x| x == K.new(5) }), r96.map { |q| q.v }]; rescue => e; p [96, :raised, e.class]; end
r97 = [K.new(5)]
begin; p [97, (r97.group_by { |x| x }), r97.map { |q| q.v }]; rescue => e; p [97, :raised, e.class]; end
r98 = [K.new(5)]
begin; p [98, (r98.each_with_object([]) { |x, acc| acc << x }), r98.map { |q| q.v }]; rescue => e; p [98, :raised, e.class]; end
r99 = [K.new(5)]
begin; p [99, (r99.inject { |a, b| a }), r99.map { |q| q.v }]; rescue => e; p [99, :raised, e.class]; end
r100 = [K.new(5)]
begin; p [100, (r100.tally), r100.map { |q| q.v }]; rescue => e; p [100, :raised, e.class]; end
r101 = [K.new(5)]
begin; p [101, (r101.to_h { |x| [x, 1] }), r101.map { |q| q.v }]; rescue => e; p [101, :raised, e.class]; end
r102 = [K.new(5)]
begin; p [102, (r102.each_with_index { |x, i| x }), r102.map { |q| q.v }]; rescue => e; p [102, :raised, e.class]; end
r103 = [K.new(5)]
begin; p [103, (r103.send(:size)), r103.map { |q| q.v }]; rescue => e; p [103, :raised, e.class]; end
r104 = [K.new(5)]
begin; p [104, (r104.public_send(:first)), r104.map { |q| q.v }]; rescue => e; p [104, :raised, e.class]; end
r105 = [K.new(5)]
begin; p [105, (r105.map(&:to_s)), r105.map { |q| q.v }]; rescue => e; p [105, :raised, e.class]; end
r106 = [K.new(5)]
begin; p [106, (r106.max.class), r106.map { |q| q.v }]; rescue => e; p [106, :raised, e.class]; end
r107 = [K.new(5)]
begin; p [107, (r107.first.class), r107.map { |q| q.v }]; rescue => e; p [107, :raised, e.class]; end
