# casecmp? compares the case folding of both sides, so accented letters
# match across case, as in CRuby: "É".casecmp?("é") is true.
p "héllo wörld".casecmp?("HÉLLO WÖRLD")
p "É".casecmp?("é")
p "é".casecmp?("e")
p "straße".casecmp?("STRASSE")
p "Łódź".casecmp?("łÓDŹ")
p "µ".casecmp?("μ")
p "ſ".casecmp?("S")
p "abc".casecmp?("ABC")
p "abc".casecmp?("ABD")
p "é".casecmp?("éx")
p :"Été".casecmp?(:"éTÉ")
xs = ["École", 1]
p xs[0].casecmp?("éCOLE")
p xs[0].casecmp?(2)
p "É".casecmp("é")
