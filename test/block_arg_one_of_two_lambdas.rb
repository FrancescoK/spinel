def m(f)
  pr = f ? lambda { |s| s + "!" } : lambda { |s| s + "?" }
  p ["a", "b"].map(&pr)
  p "ab".each_char.map(&pr)
  p "a-b".sub(/-/, &pr)
  p "a-b".gsub(/-/, &pr)
end
m(true)
m(false)
