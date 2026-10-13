# A `[]=` through a container's element with a value that is no String
# (an Integer, a Float, a Symbol, nil, true or false) does not change a
# String element: String#[]= raises TypeError for it. Such a call does not
# make the container's Strings shared, and the answers stay CRuby's.
words = [+"ab", +"cd"]
begin
  words[0][0] = 1
rescue TypeError => e
  p e.class
end
p words

rows = [{ "k" => 1 }, { "k" => 2 }]
rows[1]["k"] = 3
rows[0]["k"] = nil
p rows

mixed = [+"x", { "k" => 1 }]
mixed[ARGV.size + 1]["k"] = :two
p mixed

words[1] << "!"
p words
