# a qualified superclass (`Search::Base`) the module does not hold raises
# NameError at the header, before the body
module Search
  class Bypass < Search::Base
    puts "body"
  end
end
puts "ok"
