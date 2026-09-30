p RUBY_VERSION
p RUBY_ENGINE_VERSION
if RUBY_VERSION >= "4.0"
  puts "4.0 path"
else
  puts "3.x path"
end
