# `klass::CONST` on a class value reads the constant of whichever class the
# value carries, switching over every class that owns one. The switch took
# only the first 64 such classes, so a read through any later one raised
# NameError though the class defines the constant.
module Probe
  class K0; CODE = 0; end
  class K1; CODE = 1; end
  class K2; CODE = 2; end
  class K3; CODE = 3; end
  class K4; CODE = 4; end
  class K5; CODE = 5; end
  class K6; CODE = 6; end
  class K7; CODE = 7; end
  class K8; CODE = 8; end
  class K9; CODE = 9; end
  class K10; CODE = 10; end
  class K11; CODE = 11; end
  class K12; CODE = 12; end
  class K13; CODE = 13; end
  class K14; CODE = 14; end
  class K15; CODE = 15; end
  class K16; CODE = 16; end
  class K17; CODE = 17; end
  class K18; CODE = 18; end
  class K19; CODE = 19; end
  class K20; CODE = 20; end
  class K21; CODE = 21; end
  class K22; CODE = 22; end
  class K23; CODE = 23; end
  class K24; CODE = 24; end
  class K25; CODE = 25; end
  class K26; CODE = 26; end
  class K27; CODE = 27; end
  class K28; CODE = 28; end
  class K29; CODE = 29; end
  class K30; CODE = 30; end
  class K31; CODE = 31; end
  class K32; CODE = 32; end
  class K33; CODE = 33; end
  class K34; CODE = 34; end
  class K35; CODE = 35; end
  class K36; CODE = 36; end
  class K37; CODE = 37; end
  class K38; CODE = 38; end
  class K39; CODE = 39; end
  class K40; CODE = 40; end
  class K41; CODE = 41; end
  class K42; CODE = 42; end
  class K43; CODE = 43; end
  class K44; CODE = 44; end
  class K45; CODE = 45; end
  class K46; CODE = 46; end
  class K47; CODE = 47; end
  class K48; CODE = 48; end
  class K49; CODE = 49; end
  class K50; CODE = 50; end
  class K51; CODE = 51; end
  class K52; CODE = 52; end
  class K53; CODE = 53; end
  class K54; CODE = 54; end
  class K55; CODE = 55; end
  class K56; CODE = 56; end
  class K57; CODE = 57; end
  class K58; CODE = 58; end
  class K59; CODE = 59; end
  class K60; CODE = 60; end
  class K61; CODE = 61; end
  class K62; CODE = 62; end
  class K63; CODE = 63; end
  class K64; CODE = 64; end
  class K65; CODE = 65; end
  class K66; CODE = 66; end
end

def code_of(klass) = klass::CODE

p code_of(Probe::K0)
p code_of(Probe::K63)
p code_of(Probe::K64)
p code_of(Probe::K66)
