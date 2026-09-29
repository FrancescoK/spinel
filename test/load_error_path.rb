# LoadError#path: a LoadError the program raises itself carries no path (nil),
# as in CRuby; activesupport's LoadError#is_missing? reads it through to_s.
e = LoadError.new("cannot load such file -- zork")
p e.path, e.path.to_s
begin
  raise LoadError, "by hand"
rescue LoadError => x
  p x.path.nil?
end
