# A strftime width pads text, the composite directives and the
# blank-padded numbers with spaces, and numbers with zeros, as CRuby
# does; a `0` or `_` flag picks the character either way, and zeros go
# after a zone's sign.
t = Time.at(1700000000).utc
%w[%10A %10a %10B %10b %10h %10p %10P %10Z %10c %10x %10X %10D %12F
   %10T %10R %12r %12v %10e %10k %10l %10%
   %10d %10j %10Y %10H %10u %10s %10m %10L
   %010A %_10d %_10H %-10H %_12Y %10z %010z].each do |f|
  puts "#{f}=[#{t.strftime(f)}]"
end
puts t.strftime("%-d/%-m %^a %^B %10A| %-10A|")
