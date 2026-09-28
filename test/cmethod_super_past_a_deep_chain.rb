class Level0
  def self.label = "base"
end
class Level1 < Level0; end
class Level2 < Level1; end
class Level3 < Level2; end
class Level4 < Level3; end
class Level5 < Level4; end
class Level6 < Level5; end
class Level7 < Level6; end
class Level8 < Level7; end
class Level9 < Level8; end
class Level10 < Level9; end
class Level11 < Level10; end
class Level12 < Level11; end
class Level13 < Level12; end
class Level14 < Level13; end
class Level15 < Level14; end
class Level16 < Level15; end
class Level17 < Level16; end
class Level18 < Level17; end
class Level19 < Level18; end
class Level20 < Level19; end
class Level21 < Level20; end
class Level22 < Level21; end
class Level23 < Level22; end
class Level24 < Level23; end
class Level25 < Level24; end
class Level26 < Level25; end
class Level27 < Level26; end
class Level28 < Level27; end
class Level29 < Level28; end
class Level30 < Level29; end
class Level31 < Level30; end
class Level32 < Level31; end
class Level33 < Level32; end
class Level34 < Level33; end
class Level35 < Level34; end
class Level36 < Level35; end
class Level37 < Level36; end
class Level38 < Level37; end
class Level39 < Level38; end
class Level40 < Level39; end
class Level41 < Level40; end
class Level42 < Level41; end
class Level43 < Level42; end
class Level44 < Level43; end
class Level45 < Level44; end
class Level46 < Level45; end
class Level47 < Level46; end
class Level48 < Level47; end
class Level49 < Level48; end
class Level50 < Level49; end
class Level51 < Level50; end
class Level52 < Level51; end
class Level53 < Level52; end
class Level54 < Level53; end
class Level55 < Level54; end
class Level56 < Level55; end
class Level57 < Level56; end
class Level58 < Level57; end
class Level59 < Level58; end
class Level60 < Level59; end
class Level61 < Level60; end
class Level62 < Level61; end
class Level63 < Level62; end
class Level64 < Level63; end
class Level65 < Level64; end
class Level66 < Level65; end
class Level67 < Level66; end
class Level68 < Level67; end
class Level69 < Level68; end
class Level70 < Level69; end
class Leaf < Level70
  def self.label = "leaf<" + super + ">"
end

p Leaf.label
