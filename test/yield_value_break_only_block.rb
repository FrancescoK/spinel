# A yielding method whose yield value is read compiles when one call's
# block only breaks and another's raises: the spliced break-only block left
# the statement expression without a value (void value not ignored, #8215).
def helper
  result = yield
  result
end

def main
  v = helper { break :broke }
  puts v
  v2 = helper { 42 }
  puts v2
  begin
    helper { raise "boom" }
  rescue => e
    puts e.message
  end
end

main
