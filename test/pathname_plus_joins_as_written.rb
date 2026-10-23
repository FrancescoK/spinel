# Pathname#+ joins the way CRuby's Pathname#plus does: the argument's leading
# "." names drop and each leading ".." takes a name off the receiver, and
# the rest is joined as written, not cleaned (`a + "b/./c"` is `a/b/./c`).
# The bundled + cleaned the joined path, so "sub/./." answered "D/sub".
require "pathname"
%w[D D/ / . ./D a/b a/.. .. ../x / ""].each do |b|
  b = "" if b == '""'
  %w[./. ./.hidden sub/./. . sub/. ./sub/x .hidden .. ../.. ../../.. b/ ./ ../ b/../c /abs x//y].each do |r|
    print (Pathname.new(b) + r).to_s, " "
  end
  puts
end
p Pathname.new("a/b").parent.to_s, Pathname.new("a").parent.to_s, Pathname.new("/").parent.to_s, Pathname.new(".").parent.to_s
p (Pathname.new("a") / "b" / "c").to_s, Pathname.new("x").join("y", "../z").to_s
