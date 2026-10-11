# $LOADED_FEATURES ($") is an Array of Strings the program can read and push
# onto. racc writes its runtime into each parser it generates, guarded by it,
# so that a second copy is skipped:
unless $".find { |f| f.end_with?("/racc/parser.rb") }
  $".push "#{__dir__}/racc/parser.rb"
  module Runtime
    def self.copy = "first"
  end
end

unless $".find { |f| f.end_with?("/racc/parser.rb") }
  $".push "#{__dir__}/racc/parser.rb"
  module Runtime
    def self.copy = "second"
  end
end

puts Runtime.copy
p $".grep(/racc/).map { |f| File.basename(f) }
p $".count { |f| f.end_with?("/racc/parser.rb") }

# both names are the one Array
p $LOADED_FEATURES.equal?($")
$LOADED_FEATURES << "/lib/loaded_features_extra.rb"
p $".include?("/lib/loaded_features_extra.rb")
p $".last
p $".frozen?
p $".class
