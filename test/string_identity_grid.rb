# frozen_string_literal: true
# String identity: a mutable String put into a holder (local, parameter,
# return, yield, block and proc, ivar, cvar, global, constant, Struct and
# Data member, Array element, Hash value, cache[k] ||=, catch/throw,
# try_convert) or passed through a method that answers it (first, fetch,
# dig, select, min, tally, to_a, concat, tap, clamp...), then mutated or
# compared through one name and read through the other. CRuby keeps one
# object, so every name sees the change and equal? holds.
#
# Each probe builds its own String (sN), passes it on to tN, and prints
# `[N, [what each name reads]]` or `[N, :raised, ErrorClass]`. Only the probes
# Spinel answers like CRuby 4.0 today are here, checked plain, under
# --int-overflow=promote, under SPINEL_GC_STRESS=1 and with --share-strings;
# the ones it gets wrong join with their fix. To add a probe, append one in the
# same shape and regenerate the .expected with
# `make test/<this file>.expected`. The probes came from a method x
# representation grid (GRIDS) run outside the repository; edit this file
# directly.
def hr_id(v) = v
def hy_id(v) = yield(v)
IS2 = Struct.new(:a, :b)
IS = Struct.new(:a, :b)
ID = Data.define(:a, :b)
begin; p [0, ((
sr0 = +"hello"
tr0 = sr0
tr0 << "!"
[sr0, tr0]
))]; rescue => e; p [0, :raised, e.class]; end
begin; p [1, ((
sr1 = +"hello"
tr1 = sr1
tr1.replace("zz")
[sr1, tr1]
))]; rescue => e; p [1, :raised, e.class]; end
begin; p [2, ((
sr2 = +"hello"
tr2 = sr2
tr2[0] = "Q"
[sr2, tr2]
))]; rescue => e; p [2, :raised, e.class]; end
begin; p [3, ((
sr3 = +"hello"
tr3 = sr3
tr3.insert(0, "<")
[sr3, tr3]
))]; rescue => e; p [3, :raised, e.class]; end
begin; p [4, ((
sr4 = +"hello"
tr4 = sr4
tr4.concat("+", "-")
[sr4, tr4]
))]; rescue => e; p [4, :raised, e.class]; end
begin; p [5, ((
sr5 = +"hello"
tr5 = sr5
tr5.upcase!
[sr5, tr5]
))]; rescue => e; p [5, :raised, e.class]; end
begin; p [6, ((
sr6 = +"hello"
tr6 = sr6
sr6 << "~"
[sr6, tr6]
))]; rescue => e; p [6, :raised, e.class]; end
begin; p [7, ((
sr7 = +"hello"
tr7 = sr7
[tr7.equal?(sr7)]
))]; rescue => e; p [7, :raised, e.class]; end
begin; p [8, ((
sr8 = +"hello"
tr8 = sr8
[tr8.object_id == sr8.object_id]
))]; rescue => e; p [8, :raised, e.class]; end
begin; p [9, ((
sr9 = +"hello"
tr9 = sr9
tr9.freeze
[sr9.frozen?, tr9.frozen?]
))]; rescue => e; p [9, :raised, e.class]; end
def hpr10(tr10, sr10)
  [tr10.equal?(sr10)]
end
begin; p [10, ((
sr10 = +"hello"
hpr10(sr10, sr10)
))]; rescue => e; p [10, :raised, e.class]; end
def hpr11(tr11, sr11)
  [tr11.object_id == sr11.object_id]
end
begin; p [11, ((
sr11 = +"hello"
hpr11(sr11, sr11)
))]; rescue => e; p [11, :raised, e.class]; end
def hpr12(tr12, sr12)
  tr12.freeze
[sr12.frozen?, tr12.frozen?]
end
begin; p [12, ((
sr12 = +"hello"
hpr12(sr12, sr12)
))]; rescue => e; p [12, :raised, e.class]; end
begin; p [13, ((
sr13 = +"hello"
tr13 = hr_id(sr13)
[tr13.equal?(sr13)]
))]; rescue => e; p [13, :raised, e.class]; end
begin; p [14, ((
sr14 = +"hello"
tr14 = hr_id(sr14)
[tr14.object_id == sr14.object_id]
))]; rescue => e; p [14, :raised, e.class]; end
begin; p [15, ((
sr15 = +"hello"
tr15 = hr_id(sr15)
tr15.freeze
[sr15.frozen?, tr15.frozen?]
))]; rescue => e; p [15, :raised, e.class]; end
begin; p [16, ((
sr16 = +"hello"
tr16 = hy_id(sr16) { |q| q }
[tr16.equal?(sr16)]
))]; rescue => e; p [16, :raised, e.class]; end
begin; p [17, ((
sr17 = +"hello"
tr17 = hy_id(sr17) { |q| q }
[tr17.object_id == sr17.object_id]
))]; rescue => e; p [17, :raised, e.class]; end
begin; p [18, ((
sr18 = +"hello"
tr18 = hy_id(sr18) { |q| q }
tr18.freeze
[sr18.frozen?, tr18.frozen?]
))]; rescue => e; p [18, :raised, e.class]; end
begin; p [19, ((
sr19 = +"hello"
outr19 = nil
[sr19].each { |tr19| outr19 = (
tr19 << "!"
[sr19, tr19]
) }
outr19
))]; rescue => e; p [19, :raised, e.class]; end
begin; p [20, ((
sr20 = +"hello"
outr20 = nil
[sr20].each { |tr20| outr20 = (
tr20.replace("zz")
[sr20, tr20]
) }
outr20
))]; rescue => e; p [20, :raised, e.class]; end
begin; p [21, ((
sr21 = +"hello"
outr21 = nil
[sr21].each { |tr21| outr21 = (
tr21.insert(0, "<")
[sr21, tr21]
) }
outr21
))]; rescue => e; p [21, :raised, e.class]; end
begin; p [22, ((
sr22 = +"hello"
outr22 = nil
[sr22].each { |tr22| outr22 = (
tr22.concat("+", "-")
[sr22, tr22]
) }
outr22
))]; rescue => e; p [22, :raised, e.class]; end
begin; p [23, ((
sr23 = +"hello"
outr23 = nil
[sr23].each { |tr23| outr23 = (
tr23.upcase!
[sr23, tr23]
) }
outr23
))]; rescue => e; p [23, :raised, e.class]; end
begin; p [24, ((
sr24 = +"hello"
outr24 = nil
[sr24].each { |tr24| outr24 = (
sr24 << "~"
[sr24, tr24]
) }
outr24
))]; rescue => e; p [24, :raised, e.class]; end
begin; p [25, ((
sr25 = +"hello"
outr25 = nil
[sr25].each { |tr25| outr25 = (
[tr25.equal?(sr25)]
) }
outr25
))]; rescue => e; p [25, :raised, e.class]; end
begin; p [26, ((
sr26 = +"hello"
outr26 = nil
[sr26].each { |tr26| outr26 = (
[tr26.object_id == sr26.object_id]
) }
outr26
))]; rescue => e; p [26, :raised, e.class]; end
begin; p [27, ((
sr27 = +"hello"
outr27 = nil
[sr27].each { |tr27| outr27 = (
tr27.freeze
[sr27.frozen?, tr27.frozen?]
) }
outr27
))]; rescue => e; p [27, :raised, e.class]; end
class Hcr28
  @@v = nil
  def self.set(v) = (@@v = v)
  def self.get = @@v
end
begin; p [28, ((
sr28 = +"hello"
Hcr28.set(sr28)
tr28 = Hcr28.get
[tr28.equal?(sr28)]
))]; rescue => e; p [28, :raised, e.class]; end
class Hcr29
  @@v = nil
  def self.set(v) = (@@v = v)
  def self.get = @@v
end
begin; p [29, ((
sr29 = +"hello"
Hcr29.set(sr29)
tr29 = Hcr29.get
[tr29.object_id == sr29.object_id]
))]; rescue => e; p [29, :raised, e.class]; end
class Hcr30
  @@v = nil
  def self.set(v) = (@@v = v)
  def self.get = @@v
end
begin; p [30, ((
sr30 = +"hello"
Hcr30.set(sr30)
tr30 = Hcr30.get
tr30.freeze
[sr30.frozen?, tr30.frozen?]
))]; rescue => e; p [30, :raised, e.class]; end
begin; p [31, ((
sr31 = +"hello"
$hgr31 = sr31
tr31 = $hgr31
[tr31.equal?(sr31)]
))]; rescue => e; p [31, :raised, e.class]; end
begin; p [32, ((
sr32 = +"hello"
$hgr32 = sr32
tr32 = $hgr32
[tr32.object_id == sr32.object_id]
))]; rescue => e; p [32, :raised, e.class]; end
begin; p [33, ((
sr33 = +"hello"
$hgr33 = sr33
tr33 = $hgr33
tr33.freeze
[sr33.frozen?, tr33.frozen?]
))]; rescue => e; p [33, :raised, e.class]; end
begin; p [34, ((
sr34 = +"hello"
HKr34 = sr34
tr34 = HKr34
[tr34.equal?(sr34)]
))]; rescue => e; p [34, :raised, e.class]; end
begin; p [35, ((
sr35 = +"hello"
HKr35 = sr35
tr35 = HKr35
[tr35.object_id == sr35.object_id]
))]; rescue => e; p [35, :raised, e.class]; end
begin; p [36, ((
sr36 = +"hello"
HKr36 = sr36
tr36 = HKr36
tr36.freeze
[sr36.frozen?, tr36.frozen?]
))]; rescue => e; p [36, :raised, e.class]; end
Hdr37 = Data.define(:v)
begin; p [37, ((
sr37 = +"hello"
tr37 = Hdr37.new(v: sr37).v
[tr37.equal?(sr37)]
))]; rescue => e; p [37, :raised, e.class]; end
Hdr38 = Data.define(:v)
begin; p [38, ((
sr38 = +"hello"
tr38 = Hdr38.new(v: sr38).v
[tr38.object_id == sr38.object_id]
))]; rescue => e; p [38, :raised, e.class]; end
Hdr39 = Data.define(:v)
begin; p [39, ((
sr39 = +"hello"
tr39 = Hdr39.new(v: sr39).v
tr39.freeze
[sr39.frozen?, tr39.frozen?]
))]; rescue => e; p [39, :raised, e.class]; end
begin; p [40, ((
sr40 = +"hello"
ar40 = [sr40]
tr40 = ar40[0]
tr40 << "!"
[sr40, tr40]
))]; rescue => e; p [40, :raised, e.class]; end
begin; p [41, ((
sr41 = +"hello"
ar41 = [sr41]
tr41 = ar41[0]
tr41.replace("zz")
[sr41, tr41]
))]; rescue => e; p [41, :raised, e.class]; end
begin; p [42, ((
sr42 = +"hello"
ar42 = [sr42]
tr42 = ar42[0]
tr42.insert(0, "<")
[sr42, tr42]
))]; rescue => e; p [42, :raised, e.class]; end
begin; p [43, ((
sr43 = +"hello"
ar43 = [sr43]
tr43 = ar43[0]
tr43.concat("+", "-")
[sr43, tr43]
))]; rescue => e; p [43, :raised, e.class]; end
begin; p [44, ((
sr44 = +"hello"
ar44 = [sr44]
tr44 = ar44[0]
tr44.upcase!
[sr44, tr44]
))]; rescue => e; p [44, :raised, e.class]; end
begin; p [45, ((
sr45 = +"hello"
ar45 = [sr45]
tr45 = ar45[0]
sr45 << "~"
[sr45, tr45]
))]; rescue => e; p [45, :raised, e.class]; end
begin; p [46, ((
sr46 = +"hello"
ar46 = [sr46]
tr46 = ar46[0]
[tr46.equal?(sr46)]
))]; rescue => e; p [46, :raised, e.class]; end
begin; p [47, ((
sr47 = +"hello"
ar47 = [sr47]
tr47 = ar47[0]
[tr47.object_id == sr47.object_id]
))]; rescue => e; p [47, :raised, e.class]; end
begin; p [48, ((
sr48 = +"hello"
ar48 = [sr48]
tr48 = ar48[0]
tr48.freeze
[sr48.frozen?, tr48.frozen?]
))]; rescue => e; p [48, :raised, e.class]; end
begin; p [49, ((
sr49 = +"hello"
$gar49 = [sr49]
tr49 = $gar49[0]
sr49 << "~"
[sr49, tr49]
))]; rescue => e; p [49, :raised, e.class]; end
begin; p [50, ((
sr50 = +"hello"
$gar50 = [sr50]
tr50 = $gar50[0]
[tr50.equal?(sr50)]
))]; rescue => e; p [50, :raised, e.class]; end
begin; p [51, ((
sr51 = +"hello"
$gar51 = [sr51]
tr51 = $gar51[0]
[tr51.object_id == sr51.object_id]
))]; rescue => e; p [51, :raised, e.class]; end
begin; p [52, ((
sr52 = +"hello"
$gar52 = [sr52]
tr52 = $gar52[0]
tr52.freeze
[sr52.frozen?, tr52.frozen?]
))]; rescue => e; p [52, :raised, e.class]; end
begin; p [53, ((
sr53 = +"hello"
hr53 = {k: sr53}
tr53 = hr53[:k]
tr53 << "!"
[sr53, tr53]
))]; rescue => e; p [53, :raised, e.class]; end
begin; p [54, ((
sr54 = +"hello"
hr54 = {k: sr54}
tr54 = hr54[:k]
tr54.replace("zz")
[sr54, tr54]
))]; rescue => e; p [54, :raised, e.class]; end
begin; p [55, ((
sr55 = +"hello"
hr55 = {k: sr55}
tr55 = hr55[:k]
tr55.insert(0, "<")
[sr55, tr55]
))]; rescue => e; p [55, :raised, e.class]; end
begin; p [56, ((
sr56 = +"hello"
hr56 = {k: sr56}
tr56 = hr56[:k]
tr56.concat("+", "-")
[sr56, tr56]
))]; rescue => e; p [56, :raised, e.class]; end
begin; p [57, ((
sr57 = +"hello"
hr57 = {k: sr57}
tr57 = hr57[:k]
tr57.upcase!
[sr57, tr57]
))]; rescue => e; p [57, :raised, e.class]; end
begin; p [58, ((
sr58 = +"hello"
hr58 = {k: sr58}
tr58 = hr58[:k]
sr58 << "~"
[sr58, tr58]
))]; rescue => e; p [58, :raised, e.class]; end
begin; p [59, ((
sr59 = +"hello"
hr59 = {k: sr59}
tr59 = hr59[:k]
[tr59.equal?(sr59)]
))]; rescue => e; p [59, :raised, e.class]; end
begin; p [60, ((
sr60 = +"hello"
hr60 = {k: sr60}
tr60 = hr60[:k]
[tr60.object_id == sr60.object_id]
))]; rescue => e; p [60, :raised, e.class]; end
begin; p [61, ((
sr61 = +"hello"
hr61 = {k: sr61}
tr61 = hr61[:k]
tr61.freeze
[sr61.frozen?, tr61.frozen?]
))]; rescue => e; p [61, :raised, e.class]; end
begin; p [62, ((
sr62 = +"hello"
cr62 = {}
cr62[:k] ||= sr62
tr62 = cr62[:k]
sr62 << "~"
[sr62, tr62]
))]; rescue => e; p [62, :raised, e.class]; end
begin; p [63, ((
sr63 = +"hello"
cr63 = {}
cr63[:k] ||= sr63
tr63 = cr63[:k]
[tr63.equal?(sr63)]
))]; rescue => e; p [63, :raised, e.class]; end
begin; p [64, ((
sr64 = +"hello"
cr64 = {}
cr64[:k] ||= sr64
tr64 = cr64[:k]
[tr64.object_id == sr64.object_id]
))]; rescue => e; p [64, :raised, e.class]; end
begin; p [65, ((
sr65 = +"hello"
cr65 = {}
cr65[:k] ||= sr65
tr65 = cr65[:k]
tr65.freeze
[sr65.frozen?, tr65.frozen?]
))]; rescue => e; p [65, :raised, e.class]; end
begin; p [66, ((
sr66 = +"hello"
tr66 = String.try_convert(sr66)
sr66 << "~"
[sr66, tr66]
))]; rescue => e; p [66, :raised, e.class]; end
begin; p [67, ((
sr67 = +"hello"
tr67 = String.try_convert(sr67)
[tr67.equal?(sr67)]
))]; rescue => e; p [67, :raised, e.class]; end
begin; p [68, ((
sr68 = +"hello"
tr68 = String.try_convert(sr68)
[tr68.object_id == sr68.object_id]
))]; rescue => e; p [68, :raised, e.class]; end
begin; p [69, ((
sr69 = +"hello"
tr69 = String.try_convert(sr69)
tr69.freeze
[sr69.frozen?, tr69.frozen?]
))]; rescue => e; p [69, :raised, e.class]; end
begin; p [70, ((
sr70 = +"hello"
sr70.scan(/l/) { |m| m << "!" }
sr70
))]; rescue => e; p [70, :raised, e.class]; end
begin; p [71, ((
sr71 = +"hello"
tr71 = sr71
sr71.scan(/l/) { tr71 << "" }
[sr71, tr71]
))]; rescue => e; p [71, :raised, e.class]; end
begin; p [72, ((
sr72 = +"hello"
ar72 = [sr72]
ar72.each { |q| q << "!" }
[sr72, ar72]
))]; rescue => e; p [72, :raised, e.class]; end
begin; p [73, ((
sr73 = +"hello"
ar73 = [sr73]
ar73.map! { |q| q << "!" }
[sr73, ar73]
))]; rescue => e; p [73, :raised, e.class]; end
begin; p [74, ((
sr74 = +"hello"
prr74 = -> { sr74 << "!" }
prr74.call
sr74
))]; rescue => e; p [74, :raised, e.class]; end
begin; p [75, ((
sr75 = +"hello"
sr75.then { |v| v.replace("w") }
sr75
))]; rescue => e; p [75, :raised, e.class]; end
def hmut_r76(v) = v << "!"
begin; p [76, ((
sr76 = +"hello"
hmut_r76(sr76)
sr76
))]; rescue => e; p [76, :raised, e.class]; end
begin; p [77, ((
sr77 = +"hello"
sr77.send(:<<, "!")
sr77
))]; rescue => e; p [77, :raised, e.class]; end
begin; p [78, ((
sr78 = +"hello"
sr78.public_send(:concat, "!")
sr78
))]; rescue => e; p [78, :raised, e.class]; end
begin; p [79, ((
sr79 = +"hello"
tr79 = sr79
tr79.freeze
sr79 << "!"
))]; rescue => e; p [79, :raised, e.class]; end
begin; p [80, ((
sr80 = +"hello"
tr80 = sr80.dup
tr80 << "!"
[sr80, tr80]
))]; rescue => e; p [80, :raised, e.class]; end
begin; p [81, ((
sr81 = +"hello"
tr81 = +sr81
tr81 << "!"
[sr81, tr81, tr81.equal?(sr81)]
))]; rescue => e; p [81, :raised, e.class]; end
begin; p [82, ((
sr82 = +"hello"
tr82 = -sr82
[tr82.frozen?, tr82.equal?(sr82)]
))]; rescue => e; p [82, :raised, e.class]; end
begin; p [83, ((
sr83 = +"hello"
ar83 = [sr83] * 2
ar83[1] << "!"
[sr83, ar83]
))]; rescue => e; p [83, :raised, e.class]; end
begin; p [84, ((
sr84 = +"hello"
hr84 = Hash.new(sr84)
hr84[:x] << "!"
[sr84, hr84[:y]]
))]; rescue => e; p [84, :raised, e.class]; end
begin; p [85, ((
e0r85 = +"e0"
e1r85 = +"e1"
e2r85 = +"e2"
a0r85 = +"a0"
a1r85 = +"a1"
a2r85 = +"a2"
k0r85 = +"a"
k1r85 = +"b"
rrr85 = [e0r85, e1r85, e2r85]
resr85 = (rrr85.fetch(0))
tr85 = resr85
[tr85.equal?(e0r85), tr85 == e0r85]
))]; rescue => e; p [85, :raised, e.class]; end
begin; p [86, ((
e0r86 = +"e0"
e1r86 = +"e1"
e2r86 = +"e2"
a0r86 = +"a0"
a1r86 = +"a1"
a2r86 = +"a2"
k0r86 = +"a"
k1r86 = +"b"
rrr86 = [e0r86, e1r86, e2r86]
resr86 = (rrr86.dig(0))
tr86 = resr86
[tr86.equal?(e0r86), tr86 == e0r86]
))]; rescue => e; p [86, :raised, e.class]; end
begin; p [87, ((
e0r87 = +"e0"
e1r87 = +"e1"
e2r87 = +"e2"
a0r87 = +"a0"
a1r87 = +"a1"
a2r87 = +"a2"
k0r87 = +"a"
k1r87 = +"b"
rrr87 = [e0r87, e1r87, e2r87]
resr87 = (rrr87.first)
tr87 = resr87
[tr87.equal?(e0r87), tr87 == e0r87]
))]; rescue => e; p [87, :raised, e.class]; end
begin; p [88, ((
e0r88 = +"e0"
e1r88 = +"e1"
e2r88 = +"e2"
a0r88 = +"a0"
a1r88 = +"a1"
a2r88 = +"a2"
k0r88 = +"a"
k1r88 = +"b"
rrr88 = [e0r88, e1r88, e2r88]
resr88 = (rrr88.last)
tr88 = resr88
[tr88.equal?(e2r88), tr88 == e2r88]
))]; rescue => e; p [88, :raised, e.class]; end
begin; p [89, ((
e0r89 = +"e0"
e1r89 = +"e1"
e2r89 = +"e2"
a0r89 = +"a0"
a1r89 = +"a1"
a2r89 = +"a2"
k0r89 = +"a"
k1r89 = +"b"
rrr89 = [e0r89, e1r89, e2r89]
resr89 = (rrr89.pop(2))
tr89 = resr89[0]
[tr89.equal?(e1r89), tr89 == e1r89]
))]; rescue => e; p [89, :raised, e.class]; end
begin; p [90, ((
e0r90 = +"e0"
e1r90 = +"e1"
e2r90 = +"e2"
a0r90 = +"a0"
a1r90 = +"a1"
a2r90 = +"a2"
k0r90 = +"a"
k1r90 = +"b"
rrr90 = [e0r90, e1r90, e2r90]
resr90 = (rrr90.reverse)
tr90 = resr90[0]
tr90 << "!"
[e2r90, tr90]
))]; rescue => e; p [90, :raised, e.class]; end
begin; p [91, ((
e0r91 = +"e0"
e1r91 = +"e1"
e2r91 = +"e2"
a0r91 = +"a0"
a1r91 = +"a1"
a2r91 = +"a2"
k0r91 = +"a"
k1r91 = +"b"
rrr91 = [e0r91, e1r91, e2r91]
resr91 = (rrr91.reverse)
tr91 = resr91[0]
[tr91.equal?(e2r91), tr91 == e2r91]
))]; rescue => e; p [91, :raised, e.class]; end
begin; p [92, ((
e0r92 = +"e0"
e1r92 = +"e1"
e2r92 = +"e2"
a0r92 = +"a0"
a1r92 = +"a1"
a2r92 = +"a2"
k0r92 = +"a"
k1r92 = +"b"
rrr92 = [e0r92, e1r92, e2r92]
resr92 = (rrr92.sort)
tr92 = resr92[0]
tr92 << "!"
[e0r92, tr92]
))]; rescue => e; p [92, :raised, e.class]; end
begin; p [93, ((
e0r93 = +"e0"
e1r93 = +"e1"
e2r93 = +"e2"
a0r93 = +"a0"
a1r93 = +"a1"
a2r93 = +"a2"
k0r93 = +"a"
k1r93 = +"b"
rrr93 = [e0r93, e1r93, e2r93]
resr93 = (rrr93.sort)
tr93 = resr93[0]
[tr93.equal?(e0r93), tr93 == e0r93]
))]; rescue => e; p [93, :raised, e.class]; end
begin; p [94, ((
e0r94 = +"e0"
e1r94 = +"e1"
e2r94 = +"e2"
a0r94 = +"a0"
a1r94 = +"a1"
a2r94 = +"a2"
k0r94 = +"a"
k1r94 = +"b"
rrr94 = [e0r94, e1r94, e2r94]
resr94 = (rrr94.min)
tr94 = resr94
[tr94.equal?(e0r94), tr94 == e0r94]
))]; rescue => e; p [94, :raised, e.class]; end
begin; p [95, ((
e0r95 = +"e0"
e1r95 = +"e1"
e2r95 = +"e2"
a0r95 = +"a0"
a1r95 = +"a1"
a2r95 = +"a2"
k0r95 = +"a"
k1r95 = +"b"
rrr95 = [e0r95, e1r95, e2r95]
resr95 = (rrr95.max)
tr95 = resr95
[tr95.equal?(e2r95), tr95 == e2r95]
))]; rescue => e; p [95, :raised, e.class]; end
begin; p [96, ((
e0r96 = +"e0"
e1r96 = +"e1"
e2r96 = +"e2"
a0r96 = +"a0"
a1r96 = +"a1"
a2r96 = +"a2"
k0r96 = +"a"
k1r96 = +"b"
rrr96 = [e0r96, e1r96, e2r96]
resr96 = (rrr96.take(2))
tr96 = resr96[0]
tr96 << "!"
[e0r96, tr96]
))]; rescue => e; p [96, :raised, e.class]; end
begin; p [97, ((
e0r97 = +"e0"
e1r97 = +"e1"
e2r97 = +"e2"
a0r97 = +"a0"
a1r97 = +"a1"
a2r97 = +"a2"
k0r97 = +"a"
k1r97 = +"b"
rrr97 = [e0r97, e1r97, e2r97]
resr97 = (rrr97.take(2))
tr97 = resr97[0]
[tr97.equal?(e0r97), tr97 == e0r97]
))]; rescue => e; p [97, :raised, e.class]; end
begin; p [98, ((
e0r98 = +"e0"
e1r98 = +"e1"
e2r98 = +"e2"
a0r98 = +"a0"
a1r98 = +"a1"
a2r98 = +"a2"
k0r98 = +"a"
k1r98 = +"b"
rrr98 = [e0r98, e1r98, e2r98]
resr98 = (rrr98.each_slice(2).to_a)
tr98 = resr98[0][0]
[tr98.equal?(e0r98), tr98 == e0r98]
))]; rescue => e; p [98, :raised, e.class]; end
begin; p [99, ((
e0r99 = +"e0"
e1r99 = +"e1"
e2r99 = +"e2"
a0r99 = +"a0"
a1r99 = +"a1"
a2r99 = +"a2"
k0r99 = +"a"
k1r99 = +"b"
rrr99 = {k0r99 => e0r99, k1r99 => e1r99}
ks0r99 = rrr99.keys[0]
ks1r99 = rrr99.keys[1]
resr99 = (rrr99.fetch(k0r99))
tr99 = resr99
[tr99.equal?(e0r99), tr99 == e0r99]
))]; rescue => e; p [99, :raised, e.class]; end
begin; p [100, ((
e0r100 = +"e0"
e1r100 = +"e1"
e2r100 = +"e2"
a0r100 = +"a0"
a1r100 = +"a1"
a2r100 = +"a2"
k0r100 = +"a"
k1r100 = +"b"
rrr100 = {k0r100 => e0r100, k1r100 => e1r100}
ks0r100 = rrr100.keys[0]
ks1r100 = rrr100.keys[1]
resr100 = (rrr100.dig(k0r100))
tr100 = resr100
[tr100.equal?(e0r100), tr100 == e0r100]
))]; rescue => e; p [100, :raised, e.class]; end
begin; p [101, ((
e0r101 = +"e0"
e1r101 = +"e1"
e2r101 = +"e2"
a0r101 = +"a0"
a1r101 = +"a1"
a2r101 = +"a2"
k0r101 = +"a"
k1r101 = +"b"
rrr101 = {k0r101 => e0r101, k1r101 => e1r101}
ks0r101 = rrr101.keys[0]
ks1r101 = rrr101.keys[1]
resr101 = (rrr101.values)
tr101 = resr101[0]
tr101 << "!"
[e0r101, tr101]
))]; rescue => e; p [101, :raised, e.class]; end
begin; p [102, ((
e0r102 = +"e0"
e1r102 = +"e1"
e2r102 = +"e2"
a0r102 = +"a0"
a1r102 = +"a1"
a2r102 = +"a2"
k0r102 = +"a"
k1r102 = +"b"
rrr102 = {k0r102 => e0r102, k1r102 => e1r102}
ks0r102 = rrr102.keys[0]
ks1r102 = rrr102.keys[1]
resr102 = (rrr102.values)
tr102 = resr102[0]
[tr102.equal?(e0r102), tr102 == e0r102]
))]; rescue => e; p [102, :raised, e.class]; end
begin; p [103, ((
e0r103 = +"e0"
e1r103 = +"e1"
e2r103 = +"e2"
a0r103 = +"a0"
a1r103 = +"a1"
a2r103 = +"a2"
k0r103 = +"a"
k1r103 = +"b"
rrr103 = {k0r103 => e0r103, k1r103 => e1r103}
ks0r103 = rrr103.keys[0]
ks1r103 = rrr103.keys[1]
resr103 = (rrr103.to_a)
tr103 = resr103[0][0]
tr103 << "!"
[ks0r103, tr103]
))]; rescue => e; p [103, :raised, e.class]; end
begin; p [104, ((
e0r104 = +"e0"
e1r104 = +"e1"
e2r104 = +"e2"
a0r104 = +"a0"
a1r104 = +"a1"
a2r104 = +"a2"
k0r104 = +"a"
k1r104 = +"b"
rrr104 = {k0r104 => e0r104, k1r104 => e1r104}
ks0r104 = rrr104.keys[0]
ks1r104 = rrr104.keys[1]
resr104 = (rrr104.to_a)
tr104 = resr104[0][0]
[tr104.equal?(ks0r104), tr104 == ks0r104]
))]; rescue => e; p [104, :raised, e.class]; end
begin; p [105, ((
e0r105 = +"e0"
e1r105 = +"e1"
e2r105 = +"e2"
a0r105 = +"a0"
a1r105 = +"a1"
a2r105 = +"a2"
k0r105 = +"a"
k1r105 = +"b"
rrr105 = +"hello"
resr105 = (rrr105.to_s)
tr105 = resr105
tr105 << "!"
[rrr105, tr105]
))]; rescue => e; p [105, :raised, e.class]; end
begin; p [106, ((
e0r106 = +"e0"
e1r106 = +"e1"
e2r106 = +"e2"
a0r106 = +"a0"
a1r106 = +"a1"
a2r106 = +"a2"
k0r106 = +"a"
k1r106 = +"b"
rrr106 = +"hello"
resr106 = (rrr106.to_s)
tr106 = resr106
[tr106.equal?(rrr106), tr106 == rrr106]
))]; rescue => e; p [106, :raised, e.class]; end
begin; p [107, ((
e0r107 = +"e0"
e1r107 = +"e1"
e2r107 = +"e2"
a0r107 = +"a0"
a1r107 = +"a1"
a2r107 = +"a2"
k0r107 = +"a"
k1r107 = +"b"
rrr107 = +"hello"
resr107 = (rrr107.clamp(a0r107, a1r107))
tr107 = resr107
[tr107.equal?(a1r107), tr107 == a1r107]
))]; rescue => e; p [107, :raised, e.class]; end
begin; p [108, ((
e0r108 = +"e0"
e1r108 = +"e1"
e2r108 = +"e2"
a0r108 = +"a0"
a1r108 = +"a1"
a2r108 = +"a2"
k0r108 = +"a"
k1r108 = +"b"
rrr108 = +"hello"
resr108 = (Array.try_convert([rrr108]))
tr108 = resr108[0]
[tr108.equal?(rrr108), tr108 == rrr108]
))]; rescue => e; p [108, :raised, e.class]; end
