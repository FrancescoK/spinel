# A class extended with 40 modules, one of them twice. Whether each mixin's
# module is already among the ancestors is asked once per mixin: asked again
# for every earlier mixin at each search, the compile time doubled with each
# extend. The repeated extend leaves M7 where it is, so M40's who answers.
module M1
  def m1 = 1
  def who = 1
end
module M2
  def m2 = 2
  def who = 2
end
module M3
  def m3 = 3
  def who = 3
end
module M4
  def m4 = 4
  def who = 4
end
module M5
  def m5 = 5
  def who = 5
end
module M6
  def m6 = 6
  def who = 6
end
module M7
  def m7 = 7
  def who = 7
end
module M8
  def m8 = 8
  def who = 8
end
module M9
  def m9 = 9
  def who = 9
end
module M10
  def m10 = 10
  def who = 10
end
module M11
  def m11 = 11
  def who = 11
end
module M12
  def m12 = 12
  def who = 12
end
module M13
  def m13 = 13
  def who = 13
end
module M14
  def m14 = 14
  def who = 14
end
module M15
  def m15 = 15
  def who = 15
end
module M16
  def m16 = 16
  def who = 16
end
module M17
  def m17 = 17
  def who = 17
end
module M18
  def m18 = 18
  def who = 18
end
module M19
  def m19 = 19
  def who = 19
end
module M20
  def m20 = 20
  def who = 20
end
module M21
  def m21 = 21
  def who = 21
end
module M22
  def m22 = 22
  def who = 22
end
module M23
  def m23 = 23
  def who = 23
end
module M24
  def m24 = 24
  def who = 24
end
module M25
  def m25 = 25
  def who = 25
end
module M26
  def m26 = 26
  def who = 26
end
module M27
  def m27 = 27
  def who = 27
end
module M28
  def m28 = 28
  def who = 28
end
module M29
  def m29 = 29
  def who = 29
end
module M30
  def m30 = 30
  def who = 30
end
module M31
  def m31 = 31
  def who = 31
end
module M32
  def m32 = 32
  def who = 32
end
module M33
  def m33 = 33
  def who = 33
end
module M34
  def m34 = 34
  def who = 34
end
module M35
  def m35 = 35
  def who = 35
end
module M36
  def m36 = 36
  def who = 36
end
module M37
  def m37 = 37
  def who = 37
end
module M38
  def m38 = 38
  def who = 38
end
module M39
  def m39 = 39
  def who = 39
end
module M40
  def m40 = 40
  def who = 40
end
class K
  extend M1
  extend M2
  extend M3
  extend M4
  extend M5
  extend M6
  extend M7
  extend M8
  extend M9
  extend M10
  extend M11
  extend M12
  extend M13
  extend M14
  extend M15
  extend M16
  extend M17
  extend M18
  extend M19
  extend M20
  extend M21
  extend M22
  extend M23
  extend M24
  extend M25
  extend M26
  extend M27
  extend M28
  extend M29
  extend M30
  extend M31
  extend M32
  extend M33
  extend M34
  extend M35
  extend M36
  extend M37
  extend M38
  extend M39
  extend M40
  extend M7
  p who
end
p K.who, K.m40, K.m1
