# The same call past the plan, where one method of the name answers a String
# an ivar holds: the answer may be that String, which the call's caller and
# the ivar both name. The two String representations refused the change as
# one through a String shared with another name; with one, the String is the
# same object under every name and the program answers as CRuby does.

class K0; def initialize = @v = 0; def inspect = "K0(#{@v})"; end
class K1; def initialize = @v = 1; def inspect = "K1(#{@v})"; end
class K2; def initialize = @v = 2; def inspect = "K2(#{@v})"; end
class K3; def initialize = @v = 3; def inspect = "K3(#{@v})"; end
class K4; def initialize = @v = 4; def inspect = "K4(#{@v})"; end
class K5; def initialize = @v = 5; def inspect = "K5(#{@v})"; end
class K6; def initialize = @v = 6; def inspect = "K6(#{@v})"; end
class K7; def initialize = @v = 7; def inspect = "K7(#{@v})"; end
class K8; def initialize = @v = 8; def inspect = "K8(#{@v})"; end
class K9; def initialize = @v = 9; def inspect = "K9(#{@v})"; end
class K10; def initialize = @v = 10; def inspect = "K10(#{@v})"; end
class K11; def initialize = @v = 11; def inspect = "K11(#{@v})"; end
class K12; def initialize = @v = 12; def inspect = "K12(#{@v})"; end
class K13; def initialize = @v = 13; def inspect = "K13(#{@v})"; end
class K14; def initialize = @v = 14; def inspect = "K14(#{@v})"; end
class K15; def initialize = @v = 15; def inspect = "K15(#{@v})"; end
class K16; def initialize = @v = 16; def inspect = "K16(#{@v})"; end
class K17; def initialize = @v = 17; def inspect = "K17(#{@v})"; end
class K18; def initialize = @v = 18; def inspect = "K18(#{@v})"; end
class K19; def initialize = @v = 19; def inspect = "K19(#{@v})"; end
class K20; def initialize = @v = 20; def inspect = "K20(#{@v})"; end
class K21; def initialize = @v = 21; def inspect = "K21(#{@v})"; end
class K22; def initialize = @v = 22; def inspect = "K22(#{@v})"; end
class K23; def initialize = @v = 23; def inspect = "K23(#{@v})"; end
class K24; def initialize = @v = 24; def inspect = "K24(#{@v})"; end
class K25; def initialize = @v = 25; def inspect = "K25(#{@v})"; end
class K26; def initialize = @v = 26; def inspect = "K26(#{@v})"; end
class K27; def initialize = @v = 27; def inspect = "K27(#{@v})"; end
class K28; def initialize = @v = 28; def inspect = "K28(#{@v})"; end
class K29; def initialize = @v = 29; def inspect = "K29(#{@v})"; end
class K30; def initialize = @v = 30; def inspect = "K30(#{@v})"; end
class K31; def initialize = @v = 31; def inspect = "K31(#{@v})"; end
class K32; def initialize = @v = 32; def inspect = "K32(#{@v})"; end
class K33; def initialize = @v = 33; def inspect = "K33(#{@v})"; end
class K34; def initialize = @v = 34; def inspect = "K34(#{@v})"; end
class K35; def initialize = @v = 35; def inspect = "K35(#{@v})"; end
class K36; def initialize = @v = 36; def inspect = "K36(#{@v})"; end
class K37; def initialize = @v = 37; def inspect = "K37(#{@v})"; end
class K38; def initialize = @v = 38; def inspect = "K38(#{@v})"; end
class K39; def initialize = @v = 39; def inspect = "K39(#{@v})"; end
class K40; def initialize = @v = 40; def inspect = "K40(#{@v})"; end
class K41; def initialize = @v = 41; def inspect = "K41(#{@v})"; end
class K42; def initialize = @v = 42; def inspect = "K42(#{@v})"; end
class K43; def initialize = @v = 43; def inspect = "K43(#{@v})"; end
class K44; def initialize = @v = 44; def inspect = "K44(#{@v})"; end
class K45; def initialize = @v = 45; def inspect = "K45(#{@v})"; end
class K46; def initialize = @v = 46; def inspect = "K46(#{@v})"; end
class K47; def initialize = @v = 47; def inspect = "K47(#{@v})"; end
class K48; def initialize = @v = 48; def inspect = "K48(#{@v})"; end
class K49; def initialize = @v = 49; def inspect = "K49(#{@v})"; end
class K50; def initialize = @v = 50; def inspect = "K50(#{@v})"; end
class K51; def initialize = @v = 51; def inspect = "K51(#{@v})"; end
class K52; def initialize = @v = 52; def inspect = "K52(#{@v})"; end
class K53; def initialize = @v = 53; def inspect = "K53(#{@v})"; end
class K54; def initialize = @v = 54; def inspect = "K54(#{@v})"; end
class K55; def initialize = @v = 55; def inspect = "K55(#{@v})"; end
class K56; def initialize = @v = 56; def inspect = "K56(#{@v})"; end
class K57; def initialize = @v = 57; def inspect = "K57(#{@v})"; end
class K58; def initialize = @v = 58; def inspect = "K58(#{@v})"; end
class K59; def initialize = @v = 59; def inspect = "K59(#{@v})"; end
class K60; def initialize = @v = 60; def inspect = "K60(#{@v})"; end
class K61; def initialize = @v = 61; def inspect = "K61(#{@v})"; end
class K62; def initialize = @v = 62; def inspect = "K62(#{@v})"; end
class K63; def initialize = @v = 63; def inspect = "K63(#{@v})"; end
class K64; def initialize = @v = 64; def inspect = "K64(#{@v})"; end
class K65; def initialize = @v = 65; def inspect = "K65(#{@v})"; end
class K66; def initialize = @v = 66; def inspect = "K66(#{@v})"; end
class K67; def initialize = @v = 67; def inspect = "K67(#{@v})"; end
class K68; def initialize = @v = 68; def inspect = "K68(#{@v})"; end
class K69; def initialize = @v = 69; def inspect = "K69(#{@v})"; end
class Abstract; def inspect = raise(NoMethodError, "abstract"); end
class Wrapped; def initialize = @t = 1; def inspect; @t; super; end; end
class Named; def initialize = @name = +"named"; def inspect = @name; def grow = @name << "+"; end

module Util
  def self.lit(x) = x.inspect
end
objs = [K0.new, K1.new, K2.new, K3.new, K4.new, K5.new, K6.new, K7.new, K8.new, K9.new, K10.new, K11.new, K12.new, K13.new, K14.new, K15.new, K16.new, K17.new, K18.new, K19.new, K20.new, K21.new, K22.new, K23.new, K24.new, K25.new, K26.new, K27.new, K28.new, K29.new, K30.new, K31.new, K32.new, K33.new, K34.new, K35.new, K36.new, K37.new, K38.new, K39.new, K40.new, K41.new, K42.new, K43.new, K44.new, K45.new, K46.new, K47.new, K48.new, K49.new, K50.new, K51.new, K52.new, K53.new, K54.new, K55.new, K56.new, K57.new, K58.new, K59.new, K60.new, K61.new, K62.new, K63.new, K64.new, K65.new, K66.new, K67.new, K68.new, K69.new, Abstract.new, Wrapped.new, Named.new]
o = objs[ARGV.size * 3]
s = Util.lit(o)
t = Util.lit("str")
names = { a: s, b: t }
s << "!"
p names[:a], names[:b], s
p Util.lit(objs[1]), Util.lit(nil), Util.lit(:sym)
objs.last.grow
