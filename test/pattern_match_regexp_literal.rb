# A Regexp literal pattern (`in /re/`, `value in /re/`) is Regexp#===: a String that matches, and no nil or other scalar (#7712).
unset = ENV["SPINEL_REPRO_NEVER_SET"]
puts "nil in /1/          => #{unset in /1/}"
puts "nil in /1/ | /2/    => #{unset in /1/ | /2/}"
puts "case nil in /1/     => #{case unset; in /1/ then true; else false; end}"
puts "\"x\" in /1/        => #{"x" in /1/}"
puts "\"1\" in /1/        => #{"1" in /1/}"
puts "\"2\" in /1/ | /2/  => #{"2" in /1/ | /2/}"
x = [1, "a2", nil, :s2][1]
r = case x
    in /a\d/ then "re"
    in Integer then "int"
    else "other"
    end
puts r
[1, "b3", nil, :c3, 2.5, true].each do |v|
  puts(case v
       in /\d/ then "m #{v.inspect}"
       in nil then "nil"
       else "no #{v.inspect}"
       end)
end
n = 5
puts(case n; in /5/ then "int-match"; else "int-no"; end)
