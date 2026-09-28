# File.delete and File.unlink with no path delete nothing and answer 0, as
# CRuby does; on 62f376e7 they raised NoMethodError at run time.
p File.delete
p File.unlink()
n = File.delete
p n + 1
