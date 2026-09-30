return if RUBY_VERSION >= "3"
class Gated; end
puts "gated body (must not run)"
