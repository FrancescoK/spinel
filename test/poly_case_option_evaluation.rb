# Case options run in order even when the boxed receiver has no case method.
def case_option(label)
  puts label
  :turkic
end
[1, "abc", :abc].each do |value|
  begin
    p value.upcase(case_option("first"), case_option("second"))
  rescue => e
    p e.class
  end
  begin
    p value.downcase(case_option("first"), case_option("second"))
  rescue => e
    p e.class
  end
  begin
    p value.capitalize(case_option("first"), case_option("second"))
  rescue => e
    p e.class
  end
  begin
    p value.swapcase(case_option("first"), case_option("second"))
  rescue => e
    p e.class
  end
end
# A later option must not collect the dynamically allocated earlier one.
def allocating_option
  20.times { "allocation#{1}".dup }
  :turkic
end
begin
  ["abc", 1][0].upcase("invalid#{1}", allocating_option)
rescue => e
  p e.class
end
# A no-argument option call must run before rejecting a boxed receiver.
def invalid_receiver_case_option
  puts "invalid receiver option"
  :turkic
end
invalid_receiver = [1, "abc"][0]
begin
  invalid_receiver.upcase(invalid_receiver_case_option)
rescue => e
  p e.class
end
