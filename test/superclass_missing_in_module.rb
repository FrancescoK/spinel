# `class Bypass < Base` inside `module Search` looks Base up from Search
# and then the top level: a Base nested in another module is not found,
# and the header raises NameError before the class exists
module Views
  class Base
  end
end

module Search
  class Bypass < Base
  end
end

puts "ok"
