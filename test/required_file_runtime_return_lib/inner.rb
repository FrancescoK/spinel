if ENV["SPINEL_TEST_NEVER_SET_XYZ"].nil?
  puts "inner returns"
  return
end
puts "inner tail (must not run)"
