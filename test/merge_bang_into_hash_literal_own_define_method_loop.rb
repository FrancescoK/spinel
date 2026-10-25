# define_method with a name only the run time knows may bind merge! or
# update, so a Hash literal receiver keeps the call as written.
class Hash
  %i[merge! update].each { |m| define_method(m) { |o| puts "own #{m}"; self } }
end

p({}.merge!({ a: 1 }))
p({ "q" => 1 }.update({ "a" => 2 }))
