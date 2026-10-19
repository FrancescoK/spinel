# A shared String answered by an elsif ladder of twenty arms, written to a
# local and changed in place through it. The arms were handed to the
# consumer's test with a depth that grew with each arm (the walk of the arms
# has no depth since it moved onto the iterator, but the leaf test still
# took one), so a ladder of sixteen arms or more was refused as one that
# would hand on a copy.
a = +"a"
b = +"b"
c = +"c"
k = ARGV.size + 20
r = if k == 1 then b
    elsif k == 2 then c
    elsif k == 3 then a
    elsif k == 4 then b
    elsif k == 5 then c
    elsif k == 6 then a
    elsif k == 7 then b
    elsif k == 8 then c
    elsif k == 9 then a
    elsif k == 10 then b
    elsif k == 11 then c
    elsif k == 12 then a
    elsif k == 13 then b
    elsif k == 14 then c
    elsif k == 15 then a
    elsif k == 16 then b
    elsif k == 17 then c
    elsif k == 18 then a
    elsif k == 19 then b
    elsif k == 20 then c
    else a
    end
r << "!"
p a, b, c, r
