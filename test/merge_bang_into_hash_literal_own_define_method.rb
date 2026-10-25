# A Hash#merge! of the program's own, bound with define_method, is kept
# for a Hash literal receiver.
class Hash
  define_method(:merge!) { |o| puts "defined merge!"; self }
end

p({}.merge!({ a: 1 }))
