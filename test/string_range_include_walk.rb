# include? and member? on a String range ask whether the String#upto walk
# meets the value, stopping at the first equal member; cover? and ===
# compare against the ends.
r = "a".."c"
p r.include?("bb"), r.member?("bb"), r.cover?("bb"), r === "bb"
p r.include?("b"), r.include?(""), ("a"..."c").include?("c")
p ("aa".."cc").include?("b"), ("aa".."cc").include?("bz")
p ("a".."e").include?("cc"), ("az".."bc").include?("b")
p ("1".."10").include?("5"), ("1"..."10").include?("10")
p ("A".."c").include?("_"), ("a".."zz").include?("bb")
p ("a".."zzzzz").include?("b")
p %w[a bb c].map { |s| r.include?(s) }
