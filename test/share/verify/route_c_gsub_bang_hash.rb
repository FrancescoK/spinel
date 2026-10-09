s = +"abc"
t = s
s.gsub!(/a/, "a" => "Z")
p s
p t
