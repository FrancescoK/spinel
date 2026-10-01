# ENV.merge!, update and replace took any hash literal as a String => String
# hash and handed it to the runtime's StrStrHash entry: a literal with a nil
# value, a non-String key or value, or an empty `{}` gave invalid C, and a
# hash local of another variant fell through to a NameError for ENV. Such a
# hash is now boxed and checked pair by pair at run time: a nil value deletes
# the variable, anything that is not a String raises CRuby's TypeError after
# the pairs before it are stored, and replace then drops what the hash does
# not name.
ENV["SPX_A"] = "a"
ENV.merge!("SPX_A" => nil, "SPX_B" => "b")
p ENV["SPX_A"], ENV["SPX_B"]
begin
  ENV.merge!("SPX_C" => "c", "SPX_D" => 1)
rescue TypeError => e
  p e.message
end
p ENV["SPX_C"], ENV["SPX_D"]
begin
  ENV.update(Object.new => "1", "SPX_E" => "e")
rescue TypeError => e
  p e.message
end
p ENV["SPX_E"]
h = {"SPX_F" => "f"}
h["SPX_G"] = :g if ARGV.size > 5
ENV.update(h)
p ENV["SPX_F"]
begin
  ENV.merge!(5)
rescue TypeError => e
  p e.message
end
saved = ENV.to_hash
begin
  ENV.replace("SPX_H" => "h", Object.new => Object.new)
rescue TypeError => e
  p e.message
end
p ENV["SPX_H"], ENV.to_hash == saved
ENV.replace(saved.merge("SPX_I" => "i", "SPX_B" => nil))
p ENV["SPX_I"], ENV["SPX_B"], ENV["SPX_F"]
ENV.merge!({})
p ENV["SPX_I"]
