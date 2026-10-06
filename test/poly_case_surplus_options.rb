# Surplus case options raise ArgumentError on boxed Strings and Symbols.
["Abc", :Abc, 1].each do |value|
  begin
    p value.upcase(:ascii, :turkic, :lithuanian)
  rescue => e
    p e.class
  end
  begin
    p value.downcase(:ascii, :turkic, :lithuanian)
  rescue => e
    p e.class
  end
  begin
    p value.capitalize(:ascii, :turkic, :lithuanian)
  rescue => e
    p e.class
  end
  begin
    p value.swapcase(:ascii, :turkic, :lithuanian)
  rescue => e
    p e.class
  end
end
