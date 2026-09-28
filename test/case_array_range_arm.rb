# A Range arm against an Array or a Hash subject answers false, as CRuby's
# Range#=== does, in a case statement and a case value, where the C build
# failed.
a = [1, 2]
p(case a; when (1..2) then :r; when [1, 2] then :a; else :no; end)
case a
when (1..2) then p :sr
else p :sno
end
h = { k: 1 }
p(case h; when (0..5) then :r; else :no; end)
n = 0
p(case a; when (n += 1)..3 then :r; else :no; end)
p n
