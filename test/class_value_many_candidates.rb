# A class method called on a class held in a variable dispatches on the
# class token with an arm per candidate class. Only the first 64 got one;
# from the 65th on, the call raised NoMethodError (a binding with hundreds
# of FFI::Struct subclasses reading `klass.layout`).
class Base
  def self.tag = name
end
class K0 < Base
  def self.tag = "k0"
end
class K1 < Base
  def self.tag = "k1"
end
class K2 < Base
  def self.tag = "k2"
end
class K3 < Base
  def self.tag = "k3"
end
class K4 < Base
  def self.tag = "k4"
end
class K5 < Base
  def self.tag = "k5"
end
class K6 < Base
  def self.tag = "k6"
end
class K7 < Base
  def self.tag = "k7"
end
class K8 < Base
  def self.tag = "k8"
end
class K9 < Base
  def self.tag = "k9"
end
class K10 < Base
  def self.tag = "k10"
end
class K11 < Base
  def self.tag = "k11"
end
class K12 < Base
  def self.tag = "k12"
end
class K13 < Base
  def self.tag = "k13"
end
class K14 < Base
  def self.tag = "k14"
end
class K15 < Base
  def self.tag = "k15"
end
class K16 < Base
  def self.tag = "k16"
end
class K17 < Base
  def self.tag = "k17"
end
class K18 < Base
  def self.tag = "k18"
end
class K19 < Base
  def self.tag = "k19"
end
class K20 < Base
  def self.tag = "k20"
end
class K21 < Base
  def self.tag = "k21"
end
class K22 < Base
  def self.tag = "k22"
end
class K23 < Base
  def self.tag = "k23"
end
class K24 < Base
  def self.tag = "k24"
end
class K25 < Base
  def self.tag = "k25"
end
class K26 < Base
  def self.tag = "k26"
end
class K27 < Base
  def self.tag = "k27"
end
class K28 < Base
  def self.tag = "k28"
end
class K29 < Base
  def self.tag = "k29"
end
class K30 < Base
  def self.tag = "k30"
end
class K31 < Base
  def self.tag = "k31"
end
class K32 < Base
  def self.tag = "k32"
end
class K33 < Base
  def self.tag = "k33"
end
class K34 < Base
  def self.tag = "k34"
end
class K35 < Base
  def self.tag = "k35"
end
class K36 < Base
  def self.tag = "k36"
end
class K37 < Base
  def self.tag = "k37"
end
class K38 < Base
  def self.tag = "k38"
end
class K39 < Base
  def self.tag = "k39"
end
class K40 < Base
  def self.tag = "k40"
end
class K41 < Base
  def self.tag = "k41"
end
class K42 < Base
  def self.tag = "k42"
end
class K43 < Base
  def self.tag = "k43"
end
class K44 < Base
  def self.tag = "k44"
end
class K45 < Base
  def self.tag = "k45"
end
class K46 < Base
  def self.tag = "k46"
end
class K47 < Base
  def self.tag = "k47"
end
class K48 < Base
  def self.tag = "k48"
end
class K49 < Base
  def self.tag = "k49"
end
class K50 < Base
  def self.tag = "k50"
end
class K51 < Base
  def self.tag = "k51"
end
class K52 < Base
  def self.tag = "k52"
end
class K53 < Base
  def self.tag = "k53"
end
class K54 < Base
  def self.tag = "k54"
end
class K55 < Base
  def self.tag = "k55"
end
class K56 < Base
  def self.tag = "k56"
end
class K57 < Base
  def self.tag = "k57"
end
class K58 < Base
  def self.tag = "k58"
end
class K59 < Base
  def self.tag = "k59"
end
class K60 < Base
  def self.tag = "k60"
end
class K61 < Base
  def self.tag = "k61"
end
class K62 < Base
  def self.tag = "k62"
end
class K63 < Base
  def self.tag = "k63"
end
class K64 < Base
  def self.tag = "k64"
end
class K65 < Base
  def self.tag = "k65"
end
class K66 < Base
  def self.tag = "k66"
end
class K67 < Base
  def self.tag = "k67"
end
class K68 < Base
  def self.tag = "k68"
end
class K69 < Base
  def self.tag = "k69"
end
ks = [K0, K1, K2, K3, K4, K5, K6, K7, K8, K9, K10, K11, K12, K13, K14, K15, K16, K17, K18, K19, K20, K21, K22, K23, K24, K25, K26, K27, K28, K29, K30, K31, K32, K33, K34, K35, K36, K37, K38, K39, K40, K41, K42, K43, K44, K45, K46, K47, K48, K49, K50, K51, K52, K53, K54, K55, K56, K57, K58, K59, K60, K61, K62, K63, K64, K65, K66, K67, K68, K69]
p ks.map { |k| k.tag }.last(3)
k = ks[rand(1) + 68]
p k.tag
