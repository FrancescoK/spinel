# Regexp.union over Regexps built at run time (Regexp.compile, a value held
# in a variable) as over literals: each joins by its (?on-off:src) form, a
# lone one answers itself. A Symbol alone is escaped by name, and among
# several operands, like a number or nil, it is CRuby's TypeError. A union
# of a Regexp compiled at run time and another constant's Regexp comes
# first.

module Marks
  PRESENTATION = /[\u{231A}\u{231B}]/
  KEYCAP = /[#*0-9]\u{FE0F}?\u{20E3}/
end

module Tables
  VS16 = Regexp.union(
    Regexp.compile(
      Marks::PRESENTATION.source +
      "(?<![#*0-9])" +
      "\u{FE0F}"
    ),
    Marks::KEYCAP
  )
  SEQUENCES = Regexp.union(/.[\u{1F3FB}-\u{1F3FF}\u{FE0F}]?(\u{200D}.[\u{1F3FB}-\u{1F3FF}\u{FE0F}]?)+|.[\u{1F3FB}-\u{1F3FF}]/, Marks::KEYCAP)
  ALL_AND_VS16 = Regexp.union(SEQUENCES, VS16)
end

p Tables::VS16.source
p "a\u{231A}\u{FE0F}b" =~ Tables::VS16
p "1\u{FE0F}\u{20E3}" =~ Tables::ALL_AND_VS16
p "plain" =~ Tables::ALL_AND_VS16
A = /[a-c]/
B = Regexp.compile("x" + "(?<![0-9])" + "y")
U = Regexp.union(Regexp.compile(A.source + "z"), B)
p U
p U.source
p "azq" =~ U
p "xy" =~ U
p Regexp.union(/a/i, /b/m, "c.d")
p Regexp.union
p Regexp.union("a+b")
p Regexp.union(["x", /y/])
r = /q/
p Regexp.union(r).equal?(r)
p B.to_s
p Regexp.union(:a)
begin; Regexp.union(:a, "b"); rescue TypeError => e; p e.message; end
begin; Regexp.union(1, "a"); rescue TypeError => e; p e.message; end
begin; Regexp.union(nil, "a"); rescue TypeError => e; p e.message; end
p Regexp.union([/a/])
p Regexp.union([])
p Regexp.union("a", "b").source
p Regexp.union(/a/x, /b/)
pats = %w[foo bar.baz]
p Regexp.union(*pats)
p Regexp.union(*pats) =~ "xbar.baz"
