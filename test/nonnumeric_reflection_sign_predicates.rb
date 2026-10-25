# true and false answer respond_to? from TrueClass / FalseClass, which have no
# Numeric sign predicates or other `?` names; String and Symbol likewise.
p [["x".respond_to?(:positive?), "x".respond_to?(:negative?)],
   [:x.respond_to?(:positive?), :x.respond_to?(:negative?)],
   [true.respond_to?(:positive?), true.respond_to?(:negative?)]]
p [false.respond_to?(:positive?), false.respond_to?(:negative?)]

flag = ARGV.empty?
other = !flag
p [flag.respond_to?(:positive?), other.respond_to?(:negative?), flag.respond_to?(:zero?)]

# the names they do have still answer
p [true.respond_to?(:&), false.respond_to?(:^), flag.respond_to?(:to_s), flag.respond_to?(:frozen?)]
p [1.respond_to?(:positive?), -1.5.respond_to?(:negative?)]
