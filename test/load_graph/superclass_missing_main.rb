# A superclass constant that names nothing where the header runs raises
# NameError there, before the class exists or its body runs.
# spinel: exit 1
module Views
  class Base
  end
end
puts "before"
module Search
  class Bypass < Base
    puts "body"
  end
end
puts "after"
