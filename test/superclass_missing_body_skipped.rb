# a superclass constant that names nothing raises NameError at the header:
# the class body does not run
module Search
  class Bypass < Base
    puts "body"
  end
end
puts "ok"
