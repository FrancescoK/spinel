# A parenthesized new String stored into a container: the parentheses box
# as their one statement, so the check reads that statement's mark.
v = 7
r = [+"a"]
r << (v.to_s * 2)
n = [+"t", 1]
n << (+"y" << +"z")
r[0] << "!"
p r, n
